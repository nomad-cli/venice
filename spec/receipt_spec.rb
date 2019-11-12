require 'spec_helper'

describe Venice::Receipt do
  describe 'parsing the response' do
    let(:response) { JSON.parse(File.read('./spec/fixtures/receipt_not_expired_cancelled.json')) }

    subject { Venice::Receipt.new(response) }

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
    its(:expiration_intent) { nil }

    context 'response is for expired cancelled receipt' do
      let(:response) { JSON.parse(File.read('./spec/fixtures/receipt_expired_cancelled.json')) }

      its(:expiration_intent) { 1 }
    end

    describe '.verify!' do
      subject { described_class.verify!('asdf') }

      before do
        allow_any_instance_of(Venice::Client).to receive(:json_response_from_verifying_data).and_return(response)
      end

      def stub_json_response_from_verifying_data(returns)
        counter = 0
        allow_any_instance_of(Venice::Client).to receive(:json_response_from_verifying_data) do
          begin
            returns[counter].call
          ensure
            counter += 1
          end
        end
      end

      it 'creates the receipt' do
        expect(subject).to be_an_instance_of(Venice::Receipt)
      end

      its(:environment) { is_expected.to eq 'production' }

      describe 'retrying VerificationError' do
        let(:retryable_error_response) do
          {
            'status' => 21000,
            'receipt' => {},
            'is_retryable' => true
          }
        end

        context 'with a retryable error response' do
          before do
            allow_any_instance_of(Venice::Client).to receive(:json_response_from_verifying_data).and_return(retryable_error_response, response)
          end

          it 'creates the receipt' do
            expect(subject).to be_an_instance_of(Venice::Receipt)
          end

          its(:environment) { is_expected.to eq 'production' }
          its(:production?) { is_expected.to be true }
          its(:development?) { is_expected.to be false }
        end

        context 'with 4 retryable error responses' do
          before do
            allow_any_instance_of(Venice::Client).to receive(:json_response_from_verifying_data).and_return(
              retryable_error_response,
              retryable_error_response,
              retryable_error_response,
              retryable_error_response,
              response
            )
          end

          it { expect { subject }.to raise_error(Venice::Receipt::VerificationError) }
        end

        context 'with a not retryable error response' do
          let(:error_response) do
            {
              'status' => 21000,
              'receipt' => {},
              'is_retryable' => false
            }
          end

          before do
            allow_any_instance_of(Venice::Client).to receive(:json_response_from_verifying_data).and_return(error_response, response)
          end

          it { expect { subject }.to raise_error(Venice::Receipt::VerificationError) }
        end

        context 'with production response' do
          let(:retryable_error_response) do
            {
                'status' => 21007,
                'receipt' => {},
                'is_retryable' => true
            }
          end

          before do
            returns = [
              -> { retryable_error_response },
              -> { response }
            ]
            stub_json_response_from_verifying_data(returns)
          end

          it 'creates the receipt' do
            expect(subject).to be_an_instance_of(Venice::Receipt)
          end

          its(:environment) { is_expected.to eq 'development' }
          its(:production?) { is_expected.to be false }
          its(:development?) { is_expected.to be true }
        end
      end

      describe 'retrying http error' do
        context 'given 3 http errors' do
          before do
            returns = [
              -> { raise(Net::ReadTimeout) },
              -> { raise(OpenSSL::SSL::SSLError) },
              -> { raise(Errno::ECONNRESET) },
              -> { response }
            ]
            stub_json_response_from_verifying_data(returns)
          end

          it 'creates the receipt' do
            expect(subject).to be_an_instance_of(Venice::Receipt)
          end
        end

        context 'given 4 Net::ReadTimeout' do
          before do
            returns = [
              -> { raise(Net::ReadTimeout) },
              -> { raise(Net::ReadTimeout) },
              -> { raise(Net::ReadTimeout) },
              -> { raise(Net::ReadTimeout) },
              -> { response }
            ]
            stub_json_response_from_verifying_data(returns)
          end

          it 'raises http error' do
            expect { subject }.to raise_error(Net::ReadTimeout)
          end
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
