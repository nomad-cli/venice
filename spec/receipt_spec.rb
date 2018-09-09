require 'spec_helper'

describe Venice::Receipt do
  describe 'parsing the response' do
    let(:response) do
      {
        'status' => 0,
        'environment' => 'Production',
        'receipt' => {
          'receipt_type' => 'Production',
          'adam_id' => 7654321,
          'bundle_id' => 'com.foo.bar',
          'application_version' => '2',
          'download_id' => 1234567,
          'receipt_creation_date' => '2014-06-04 23:20:47 Etc/GMT',
          'receipt_creation_date_ms' => '1401924047883',
          'receipt_creation_date_pst' => '2014-06-04 16:20:47 America/Los_Angeles',
          'request_date' => '2014-06-04 23:20:47 Etc/GMT',
          'request_date_ms' => '1401924047883',
          'request_date_pst' => '2014-06-04 16:20:47 America/Los_Angeles',
          'original_purchase_date' => '2014-05-17 02:09:45 Etc/GMT',
          'original_purchase_date_ms' => '1400292585000',
          'original_purchase_date_pst' => '2014-05-16 19:09:45 America/Los_Angeles',
          'original_application_version' => '1',
          'expiration_date' => '1401924047883',
          'in_app' => [
            {
              'quantity' => '1',
              'product_id' => 'com.foo.product1',
              'transaction_id' => '1000000070107111',
              'original_transaction_id' => '1000000061051111',
              'web_order_line_item_id' => '1000000026812043',
              'purchase_date' => '2014-05-28 14:47:53 Etc/GMT',
              'purchase_date_ms' => '1401288473000',
              'purchase_date_pst' => '2014-05-28 07:47:53 America/Los_Angeles',
              'original_purchase_date' => '2014-05-28 14:47:53 Etc/GMT',
              'original_purchase_date_ms' => '1401288473000',
              'original_purchase_date_pst' => '2014-05-28 07:47:53 America/Los_Angeles',
              'expires_date' => '2014-06-28 14:47:53 Etc/GMT',
              'is_trial_period' => 'false'
            }
          ],
          'original_json_response' => {
            'pending_renewal_info' => [
              {
                'auto_renew_product_id' => 'com.foo.product1',
                'original_transaction_id' => '37xxxxxxxxx89',
                'product_id' => 'com.foo.product1',
                'auto_renew_status' => '0',
                'is_in_billing_retry_period' => '0',
                'expiration_intent' => '1'
              }
            ]
          }
        }
      }
    end

    subject { Venice::Receipt.new(response['receipt']) }

    its(:bundle_id) { 'com.foo.bar' }
    its(:application_version) { '2' }
    its(:in_app) { should be_instance_of Array }
    its(:original_application_version) { '1' }
    its(:original_purchase_date) { should be_instance_of DateTime }
    its(:expires_at) { should be_instance_of DateTime }
    its(:receipt_type) { 'Production' }
    its(:receipt_created_at) { should be_instance_of DateTime }
    its(:adam_id) { 7654321 }
    its(:download_id) { 1234567 }
    its(:requested_at) { should be_instance_of DateTime }

    describe '.verify!' do
      subject { described_class.verify!('asdf') }

      before do
        Venice::Client.any_instance.stub(:json_response_from_verifying_data).and_return(response)
      end

      it 'creates the receipt' do
        expect(subject).to be_an_instance_of(Venice::Receipt)
      end

      end
    end

    it 'parses the pending rerenewal information' do
      expect(subject.to_hash[:pending_renewal_info]).to eql([{ expiration_intent: 1,
                                                               auto_renew_status: 0,
                                                               auto_renew_product_id: 'com.foo.product1',
                                                               is_in_billing_retry_period: false,
                                                               product_id: 'com.foo.product1',
                                                               price_consent_status: nil,
                                                               cancellation_reason: nil }])
    end
  end
end
