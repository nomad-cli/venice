require 'json'
require 'net/https'
require 'uri'

module Venice
  ITUNES_PRODUCTION_RECEIPT_VERIFICATION_ENDPOINT = 'https://buy.itunes.apple.com/verifyReceipt'
  ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT = 'https://sandbox.itunes.apple.com/verifyReceipt'

  class Client
    class << self
      def development
        new(environment: :development)
      end

      def production
        new(environment: :production)
      end
    end

    def initialize(environment: :production, verification_url: ENV['IAP_VERIFICATION_ENDPOINT'])
      @environment = environment
      @verification_url = verification_url || default_verification_url
    end

    def verify!(data, options = {})
      json = json_response_from_verifying_data(data, options)

      case json['status'].to_i
      when 0, 21006
        receipt = Receipt.new(
          attributes: json['receipt'],
          original_json_response: json
        )

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
        raise Receipt::VerificationError.new(json)
      end
    end

    private

    attr_reader :environment, :verification_url

    def default_verification_url
      case environment
      when :production then ITUNES_PRODUCTION_RECEIPT_VERIFICATION_ENDPOINT
      when :development then ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT
      end
    end

    def json_response_from_verifying_data(data, options = {})
      parameters = {
        'receipt-data' => data
      }

      parameters['password'] = options[:shared_secret] if options[:shared_secret]

      uri = URI(verification_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'
      request.body = parameters.to_json

      response = http.request(request)

      JSON.parse(response.body)
    end
  end
end
