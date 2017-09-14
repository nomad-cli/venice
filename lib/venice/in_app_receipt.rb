require 'time'

module Venice
  class InAppReceipt
    # For detailed explanations on these keys/values, see
    # https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW12

    # The number of items purchased. This value corresponds to the quantity property of
    # the SKPayment object stored in the transaction’s payment property.
    attr_reader :quantity

    # The product identifier of the item that was purchased. This value corresponds to
    # the productIdentifier property of the SKPayment object stored in the transaction’s
    # payment property.
    attr_reader :product_id

    # The transaction identifier of the item that was purchased. This value corresponds
    # to the transaction’s transactionIdentifier property.
    attr_reader :transaction_id

    # The date and time this transaction occurred. This value corresponds to the
    # transaction’s transactionDate property.
    attr_reader :purchased_at

    # A string that the App Store uses to uniquely identify the application that created
    # the payment transaction. If your server supports multiple applications, you can use
    # this value to differentiate between them. Applications that are executing in the
    # sandbox do not yet have an app-item-id assigned to them, so this key is missing from
    # receipts created by the sandbox.
    attr_reader :app_item_id

    # An arbitrary number that uniquely identifies a revision of your application. This key
    # is missing in receipts created by the sandbox.
    attr_reader :version_external_identifier

    # For a transaction that restores a previous transaction, this is the original receipt
    attr_accessor :original

    # For auto-renewable subscriptions, returns the date the subscription will expire
    attr_reader :expires_at

    # For a transaction that was canceled by Apple customer support, the time and date of the cancellation.
    attr_reader :cancellation_at


    def initialize(attributes = {})
      @quantity = Integer(attributes['quantity']) if attributes['quantity']
      @product_id = attributes['product_id']
      @transaction_id = attributes['transaction_id']
      @purchased_at = DateTime.parse(attributes['purchase_date']) if attributes['purchase_date']
      @app_item_id = attributes['app_item_id']
      @version_external_identifier = attributes['version_external_identifier']

      # expires_date is in ms since the Epoch, Time.at expects seconds
      @expires_at = Time.at(attributes['expires_date_ms'].to_i / 1000) if attributes['expires_date_ms']

      # cancellation_date is in ms since the Epoch, Time.at expects seconds
      @cancellation_at = Time.at(attributes['cancellation_date_ms'].to_i / 1000) if attributes['cancellation_date_ms']

      if attributes['original_transaction_id'] || attributes['original_purchase_date']
        original_attributes = {
          'transaction_id' => attributes['original_transaction_id'],
          'purchase_date' => attributes['original_purchase_date']
        }

        self.original = InAppReceipt.new(original_attributes)
      end

    end

    def to_hash
      {
        :quantity => @quantity,
        :product_id => @product_id,
        :transaction_id => @transaction_id,
        :purchase_date => (@purchased_at.httpdate rescue nil),
        :original_transaction_id => (@original.transaction_id rescue nil),
        :original_purchase_date => (@original.purchased_at.httpdate rescue nil),
        :app_item_id => @app_item_id,
        :version_external_identifier => @version_external_identifier,
        :expires_at => (@expires_at.httpdate rescue nil),
        :cancellation_at => (@cancellation_at.httpdate rescue nil)
      }
    end
    alias_method :to_h, :to_hash

    def to_json
      self.to_hash.to_json
    end

  end
end
