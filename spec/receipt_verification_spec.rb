require 'spec_helper'

RECEIPT_DATA = File.read(File.join(File.dirname(__FILE__), "receipt"))

describe 'Receipt Verification' do
  describe 'production' do
    it 'verifies a receipt' do

      lambda {
        receipt = Venice::Receipt.verify!(RECEIPT_DATA)
      
        receipt.quantity.should == 1
        receipt.product_id.should == "com.mindmobapp.download"
        receipt.transaction_id.should == "1000000046178817"
        receipt.original.should_not be nil
      }.should_not raise_error
    end
  end
end
