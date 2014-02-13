require 'spec_helper'

RECEIPT_DATA_BEFORE_IOS_7 = File.read(File.join(File.dirname(__FILE__), "receipt_before_ios_7"))

describe 'Receipt Verification' do

  context "verify receipt data (before iOS 7)" do
    subject { @receipt_hash ||= Venice::Receipt.verify!(RECEIPT_DATA_BEFORE_IOS_7, options) }


    context "the return_hash option is used" do
      let(:options) do
        { 
          return_hash: true 
        }
      end

      context "the response hash is correct" do
        its(["quantity"])                  { should == "1" }
        its(["product_id"])                { should == "com.mindmobapp.download" }
        its(["transaction_id"])            { should == "1000000046178817" }
        its(["bvrs"])                      { should == "20120427" }
        its(["original_purchase_date_ms"]) { should == "1335798355868" }
        its(["item_id"])                   { should == "521129812"}
      end
    end

    context "the return_hash option is not used" do
      let(:options) { {} }
      
      it "the receipt is ok" do
        lambda {
         receipt = Venice::Receipt.verify!(RECEIPT_DATA_BEFORE_IOS_7)
         receipt.quantity.should == 1
         receipt.product_id.should == "com.mindmobapp.download"
         receipt.transaction_id.should == "1000000046178817"
         receipt.original.should_not be nil
       }.should_not raise_error
      end
    end
  end
end
