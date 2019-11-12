require 'json'
require 'net/https'
require 'uri'

module Venice
  ITUNES_PRODUCTION_RECEIPT_VERIFICATION_ENDPOINT = 'https://buy.itunes.apple.com/verifyReceipt'
  ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT = 'https://sandbox.itunes.apple.com/verifyReceipt'

  module Environment
    PRODUCTION = 'production'
    DEVELOPMENT = 'development'
  end

  class Client
    attr_accessor :verification_url, :environment
    attr_writer :shared_secret
    attr_writer :exclude_old_transactions

    class << self
      def development
        client = new
        client.verification_url = ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT
        client.environment = Environment::DEVELOPMENT
        client
      end

      def production
        client = new
        client.verification_url = ITUNES_PRODUCTION_RECEIPT_VERIFICATION_ENDPOINT
        client.environment = Environment::PRODUCTION
        client
      end
    end

    def initialize
      @verification_url = ENV['IAP_VERIFICATION_ENDPOINT']
      @environment = ENV['IAP_VERIFICATION_ENVIRONMENT']
    end

    def verify!(data, options = {})
      @verification_url ||= ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT
      @environment ||= Environment::DEVELOPMENT
      @shared_secret = options[:shared_secret] if options[:shared_secret]
      @exclude_old_transactions = options[:exclude_old_transactions] if options[:exclude_old_transactions]

      json = json_response_from_verifying_data(data, options)
      json['environment'] = environment if json

      case json['status'].to_i
      when 0, 21006
        Receipt.new(json)
      else
        raise Receipt::VerificationError, json
      end
    end

    private

    def json_response_from_verifying_data(data, options = {})
      parameters = {
        'receipt-data' => data
      }

      parameters['password'] = @shared_secret if @shared_secret
      parameters['exclude-old-transactions'] = @exclude_old_transactions if @exclude_old_transactions

      uri = URI(@verification_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      http.open_timeout = options[:open_timeout] if options[:open_timeout]
      http.read_timeout = options[:read_timeout] if options[:read_timeout]

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'
      request.body = parameters.to_json

      begin
        response = http.request(request)
      rescue Timeout::Error
        raise TimeoutError
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        raise InvalidResponseError
      end
    end
  end

  class Client::TimeoutError < Timeout::Error
    def message
      'The App Store timed out.'
    end
  end

  class Client::InvalidResponseError < StandardError
    def message
      'The App Store returned invalid response'
    end
  end
end
