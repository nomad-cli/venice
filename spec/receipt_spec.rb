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

    it "should parse the origin attributes" do
      subject.original.transaction_id.should == "1000000061051565"
      subject.original.purchase_date.should be_instance_of DateTime
    end

  end
end