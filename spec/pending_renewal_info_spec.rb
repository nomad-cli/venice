require 'spec_helper'

describe Venice::PendingRenewalInfo do
  describe '.new' do
    let(:attributes) do
      {
        'auto_renew_product_id' => 'com.foo.product1',
        'original_transaction_id' => '37xxxxxxxxx89',
        'product_id' => 'com.foo.product1',
        'auto_renew_status' => '0',
        'is_in_billing_retry_period' => '0',
        'expiration_intent' => '1'
      }
    end

    subject(:pending_info) do
      described_class.new(attributes)
    end

    it 'parses the attributes correctly' do
      expect(subject.expiration_intent).to eql(1)
      expect(subject.auto_renew_status).to eql(0)
      expect(subject.auto_renew_product_id).to eql('com.foo.product1')
      expect(subject.is_in_billing_retry_period).to eql(false)
      expect(subject.product_id).to eql('com.foo.product1')
    end

    it 'outputs attributes in hash' do
      expect(subject.to_hash).to eql(expiration_intent: 1,
                                     auto_renew_status: 0,
                                     auto_renew_product_id: 'com.foo.product1',
                                     is_in_billing_retry_period: false,
                                     product_id: 'com.foo.product1',
                                     price_consent_status: nil,
                                     cancellation_reason: nil)
    end
  end
end
