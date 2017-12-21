require 'json'
require 'net/https'
require 'uri'

module Venice
  ITUNES_PRODUCTION_RECEIPT_VERIFICATION_ENDPOINT = 'https://buy.itunes.apple.com/verifyReceipt'
  ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT = 'https://sandbox.itunes.apple.com/verifyReceipt'

  class Client
    attr_accessor :verification_url
    attr_writer :shared_secret
    attr_writer :exclude_old_transactions

    class << self
      def development
        client = new
        client.verification_url = ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT
        client
      end

      def production
        client = new
        client.verification_url = ITUNES_PRODUCTION_RECEIPT_VERIFICATION_ENDPOINT
        client
      end
    end

    def initialize
      @verification_url = ENV['IAP_VERIFICATION_ENDPOINT']
    end

    def verify!(data, options = {})
      @verification_url ||= ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT
      @shared_secret = options[:shared_secret] if options[:shared_secret]
      @exclude_old_transactions = options[:exclude_old_transactions] if options[:exclude_old_transactions]

      json = json_response_from_verifying_data(data, options)
      receipt_attributes = json['receipt'].dup if json['receipt']
      receipt_attributes['original_json_response'] = json if receipt_attributes

      case json['status'].to_i
      when 0, 21006
        receipt = Receipt.new(receipt_attributes)

        # From Apple docs:
        # > Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions.
        # > The JSON representation of the receipt for the most recent renewal
        if latest_receipt_info_attributes = json['latest_receipt_info']
          # AppStore returns 'latest_receipt_info' even if we use over iOS 6. Besides, its format is an Array.
          receipt.latest_receipt_info = []
          latest_receipt_info_attributes.each do |latest_receipt_info_attribute|
            # latest_receipt_info format is identical with in_app
            receipt.latest_receipt_info << InAppReceipt.new(latest_receipt_info_attribute)
          end
        end

        return receipt
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

      JSON.parse(response.body)
    end
  end

  class Client::TimeoutError < Timeout::Error
    def message
      'The App Store timed out.'
    end
  end
end
