require 'json'
require 'net/https'
require 'uri'

module Venice
  ITUNES_PRODUCTION_RECEIPT_VERIFICATION_ENDPOINT = "https://buy.itunes.apple.com/verifyReceipt"
  ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT = "https://sandbox.itunes.apple.com/verifyReceipt"

  RECEIPT_VERIFICATION_ERRORS_BY_STATUS_CODE = {
    21000 => "The App Store could not read the JSON object you provided.",
    21002 => "The data in the receipt-data property was malformed.",
    21003 => "The receipt could not be authenticated.",
    21004 => "The shared secret you provided does not match the shared secret on file for your account.",
    21005 => "The receipt server is not currently available.",
    21006 => "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response.",
    21007 => "This receipt is a sandbox receipt, but it was sent to the production service for verification.",
    21008 => "This receipt is a production receipt, but it was sent to the sandbox service for verification."
  }

  class Client
    attr_accessor :verification_url
    attr_writer :shared_secret

    class << self
      def development
        client = self.new
        client.verification_url = ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT
        client
      end

      def production
        client = self.new
        client.verification_url = ITUNES_PRODUCTION_RECEIPT_VERIFICATION_ENDPOINT
        client
      end
    end

    def initialize
      @verification_url = ENV['IAP_VERIFICATION_ENDPOINT']
    end

    def verify!(data, options = {})
      json = json_response_from_verifying_data(data)
      status, receipt_attributes = json['status'].to_i, json['receipt']

      case status
      when 0, 21006
        receipt = Receipt.new(receipt_attributes)

        if latest_receipt_attributes = json['latest_receipt_info']
          receipt.latest = Receipt.new(latest_receipt_attributes)
        end

        if latest_expired_receipt_attributes = json['latest_expired_receipt_info']
          receipt.latest_expired = Receipt.new(latest_expired_receipt_attributes)
        end

        return receipt
      else
        raise (RECEIPT_VERIFICATION_ERRORS_BY_STATUS_CODE[status] || "Unknown Error: #{status}")
      end
    end

    private

    def json_response_from_verifying_data(data)
      parameters = {
        'receipt-data' => data
      }

      parameters['password'] = @shared_secret if @shared_secret

      uri = URI(@verification_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Accept'] = "application/json"
      request['Content-Type'] = "application/json"
      request.body = parameters.to_json

      response = http.request(request)

      JSON.parse(response.body)
    end
  end
end
