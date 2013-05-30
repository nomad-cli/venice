require 'spec_helper'

describe Venice::Client do
  let(:receipt_data) { "asdfzxcvjklqwer" }
  let(:client) { subject }

  describe "#verify!" do
    context "no shared_secret" do
      before do
        client.shared_secret = nil
      end

      it "should only include the receipt_data" do
        client.should_receive(:perform_post).with('receipt-data' => receipt_data)
        client.verify! receipt_data
      end
    end

    context "with a shared secret" do
      let(:secret) { "shhhhhh" }

      before do
        client.shared_secret = secret
      end

      it "should include the secret in the post" do
        client.should_receive(:perform_post).with('receipt-data' => receipt_data, 'password' => secret)
        client.verify! receipt_data
      end
    end
  end
end
