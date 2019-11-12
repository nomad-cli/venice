require 'spec_helper.rb'

describe Venice::InAppReceipt do
  describe '.new' do
    let :attributes do
      {
        'quantity' => 1,
        'product_id' => 'com.foo.product1',
        'transaction_id' => '1000000070107235',
        'web_order_line_item_id' => '1000000026812043',
        'purchase_date' => '2014-05-28 14:47:53 Etc/GMT',
        'purchase_date_ms' => '1401288473000',
        'purchase_date_pst' => '2014-05-28 07:47:53 America/Los_Angeles',
        'original_transaction_id' => '140xxx867509',
        'original_purchase_date' => '2014-05-28 14:47:53 Etc/GMT',
        'original_purchase_date_ms' => '1401288473000',
        'original_purchase_date_pst' => '2014-05-28 07:47:53 America/Los_Angeles',
        'is_trial_period' => 'false',
        'is_in_intro_offer_period' => 'true',
        'version_external_identifier' => '123',
        'app_item_id' => 'com.foo.app1',
        'expires_date' => '2014-06-28 07:47:53 America/Los_Angeles',
        'expires_date_ms' => '1403941673000'
      }
    end

    subject(:in_app_receipt) do
      Venice::InAppReceipt.new attributes
    end

    its(:quantity) { 1 }
    its(:product_id) { 'com.foo.product1' }
    its(:transaction_id) { '1000000070107235' }
    its(:web_order_line_item_id) { '1000000026812043' }
    its(:purchased_at) { should be_instance_of DateTime }
    its(:app_item_id) { 'com.foo.app1' }
    its(:version_external_identifier) { '123' }
    its(:is_trial_period) { false }
    its(:is_in_intro_offer_period) { true }
    its(:original) { should be_instance_of Venice::InAppReceipt }
    its(:expires_at) { should be_instance_of Time }
    its(:original_json_data) { attributes }

    it "should parse the 'original' attributes" do
      expect(subject.original).to be_instance_of Venice::InAppReceipt
      expect(subject.original.transaction_id).to eq '140xxx867509'
      expect(subject.original.purchased_at).to be_instance_of DateTime
    end

    it 'should parse expires_date when expires_date_ms is missing and expires_date is the ms epoch' do
      attributes.delete('expires_date_ms')
      attributes['expires_date'] = '1403941685000'
      expect(in_app_receipt.expires_at).to eq Time.at(1403941685000 / 1000)
    end

    it 'should output a hash with attributes' do
      expect(in_app_receipt.to_h).to include(quantity: 1,
                                         product_id: 'com.foo.product1',
                                         transaction_id: '1000000070107235',
                                         web_order_line_item_id: '1000000026812043',
                                         is_trial_period: false,
                                         is_in_intro_offer_period: true,
                                         purchase_date: 'Wed, 28 May 2014 14:47:53 GMT',
                                         original_purchase_date: 'Wed, 28 May 2014 14:47:53 GMT')
    end
  end
end
