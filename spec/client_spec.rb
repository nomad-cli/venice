require 'spec_helper'

describe Venice::Client do
  let(:receipt_data) { "asdfzxcvjklqwer" }
  let(:client) { Venice::Client.development }

  describe "#verify!" do
    context "no shared_secret set" do
      before do
        client.shared_secret = nil
      end

      it "the request should only include the receipt_data" do
        WebMock.stub_request(:post, "https://sandbox.itunes.apple.com/verifyReceipt").to_return(status: 200, body: "{}")

        client.verify! receipt_data, return_hash: true
        
        WebMock.assert_requested :post, "https://sandbox.itunes.apple.com/verifyReceipt", body: { 'receipt-data' => receipt_data }.to_json
      end
    end

    context "with a shared secret set" do
      let(:secret) { "shhhhhh" }

      before do
        client.shared_secret = secret
      end

      it "should include the secret in the post" do
        WebMock.stub_request(:post, "https://sandbox.itunes.apple.com/verifyReceipt").to_return(status: 200, body: "{}")

        client.verify! receipt_data, return_hash: true
        
        WebMock.assert_requested :post, "https://sandbox.itunes.apple.com/verifyReceipt", body: { 'receipt-data' => receipt_data, 'password' => secret }.to_json
      end
    end
  end

  after :all do
    WebMock.disable!
  end
end
