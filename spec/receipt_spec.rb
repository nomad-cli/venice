require 'spec_helper'

describe Venice::Receipt do
  describe "parsing the response" do
    let(:response) {
      {
        "receipt" => {
            "original_purchase_date_pst" => "2012-12-30 09:39:24 America/Los_Angeles",
            "unique_identifier" => "0000b031c818",
            "original_transaction_id" => "1000000061051565",
            "expires_date" => "1357074383000",
            "transaction_id" => "1000000070107235",
            "quantity" => "1",
            "product_id" => "com.foo.product1",
            "item_id" => "590265423",
            "bid" => "com.foo.bar",
            "unique_vendor_identifier" => "77FA64BC-23BB-46CF-9A42-D022494D20D5",
            "web_order_line_item_id" => "1000000026510809",
            "bvrs" => "0.1",
            "expires_date_formatted" => "2013-01-01 21:06:23 Etc/GMT",
            "purchase_date" => "2013-01-01 21:01:23 Etc/GMT",
            "purchase_date_ms" => "1357074083000",
            "expires_date_formatted_pst" => "2013-01-01 13:06:23 America/Los_Angeles",
            "purchase_date_pst" => "2013-01-01 13:01:23 America/Los_Angeles",
            "original_purchase_date" => "2012-12-30 17:39:24 Etc/GMT",
            "original_purchase_date_ms" => "1356889164000"
        },
        "status" => 21006
      }
    }
    subject { Venice::Receipt.new(response['receipt']) }

    its(:quantity) { 1 }
    its(:product_id) { "com.foo.product1" }
    its(:transaction_id) { "1000000070107235" }
    its(:unique_identifier) { "0000b031c818" }
    its(:purchase_date) { should be_instance_of DateTime }
    its(:bvrs) { "0.1" }
    its(:bid) { "com.foo.bar" }
    its(:original) { should be_instance_of Venice::Receipt }
    its(:expires_at) { should be_instance_of Time }

    it "should parse the origin attributes" do
      subject.original.transaction_id.should == "1000000061051565"
      subject.original.purchase_date.should be_instance_of DateTime
    end

    describe "#verify!" do
      before do
        client = stub
        Venice::Client.stub(:production).and_return(client)
        client.stub(:verify!).and_return(response)
      end

      let(:receipt) { Venice::Receipt.verify("asdf") }

      it "should create the receipt" do
        receipt.should_not be_nil
      end

      context "with a latest expired receipt attribute" do
        before do
          response['latest_expired_receipt_info'] =  {
            "original_purchase_date_pst" => "2012-12-30 09:39:24 America/Los_Angeles",
            "unique_identifier" => "0000b01147b8",
            "original_transaction_id" => "1000000061051565",
            "expires_date" => "1365114731000",
            "transaction_id" => "1000000070104252",
            "quantity" => "1",
            "product_id" => "com.ficklebits.nsscreencast.monthly_sub",
            "original_purchase_date_ms" => "1356889164000",
            "bid" => "com.ficklebits.nsscreencast",
            "web_order_line_item_id" => "1000000026812043",
            "bvrs" => "0.1",
            "expires_date_formatted" => "2013-04-04 22:32:11 Etc/GMT",
            "purchase_date" => "2013-04-04 22:27:11 Etc/GMT",
            "purchase_date_ms" => "1365114431000",
            "expires_date_formatted_pst" => "2013-04-04 15:32:11 America/Los_Angeles",
            "purchase_date_pst" => "2013-04-04 15:27:11 America/Los_Angeles",
            "original_purchase_date" => "2012-12-30 17:39:24 Etc/GMT",
            "item_id" => "590265423"
          }
        end

        it "should create a latest expired receipt" do
          receipt.latest_expired.should_not be_nil
        end
      end
    end

  end

end
