require 'excon'
require 'json'

module Venice
  ITUNES_PRODUCTION_RECEIPT_VERIFICATION_ENDPOINT = "https://buy.itunes.apple.com/verifyReceipt"
  ITUNES_DEVELOPMENT_RECEIPT_VERIFICATION_ENDPOINT = "https://sandbox.itunes.apple.com/verifyReceipt"

  class Client
    attr_accessor :verification_url

    def initialize
      @verification_url = ENV['IAP_VERIFICATION_ENDPOINT']
    end

    def verify!(data)
      params = {
        'receipt-data' => data
      }
      params.merge!('password' => Venice.shared_secret) if Venice.shared_secret
      perform_post(params)
    end

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

    private

    def perform_post(params)
      response = Excon.post(@verification_url, :headers => headers, :body => params.to_json)
      JSON.parse(response.body)
    end

    def headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end
  end
end
