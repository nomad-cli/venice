require 'spec_helper'

describe Venice::Client do
  let(:receipt_data) { "asdfzxcvjklqwer" }
  let(:client) { subject }

  describe "#verify!" do
    context "no shared_secret" do
      before do
        client.shared_secret = nil
        Venice::Receipt.stub :new
      end

      it "should only include the receipt_data" do
        Net::HTTP.any_instance.should_receive(:request) do |post|
          post.body.should eq({'receipt-data' => receipt_data}.to_json)
          post
        end
        client.verify! receipt_data
      end
    end

    context "with a shared secret" do
      let(:secret) { "shhhhhh" }

      before do
        client.shared_secret = secret
        Venice::Receipt.stub :new
      end

      it "should include the secret in the post" do
        Net::HTTP.any_instance.should_receive(:request) do |post|
          post.body.should eq({'receipt-data' => receipt_data, 'password' => secret}.to_json)
          post
        end
        client.verify! receipt_data
      end
    end
  end
end
