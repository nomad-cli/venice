module Venice
  class PendingRenewalInfo
    # Original JSON data returned from Apple for a PendingRenewalInfo object.
    attr_reader :original_json_data

    # For an expired subscription, the reason for the subscription expiration.
    # This key is only present for a receipt containing an expired auto-renewable subscription.
    attr_reader :expiration_intent

    # The current renewal status for the auto-renewable subscription.
    # This key is only present for auto-renewable subscription receipts, for active or expired subscriptions
    attr_reader :auto_renew_status

    # The current renewal preference for the auto-renewable subscription.
    # The value for this key corresponds to the productIdentifier property of the product that the customer’s subscription renews.
    attr_reader :auto_renew_product_id

    # For an expired subscription, whether or not Apple is still attempting to automatically renew the subscription.
    # If the customer’s subscription failed to renew because the App Store was unable to complete the transaction, this value will reflect whether or not the App Store is still trying to renew the subscription.
    attr_reader :is_in_billing_retry_period

    # The product identifier of the item that was purchased.
    # This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
    attr_reader :product_id

    # The current price consent status for a subscription price increase
    # This key is only present for auto-renewable subscription receipts if the subscription price was increased without keeping the existing price for active subscribers
    attr_reader :price_consent_status

    # For a transaction that was cancelled, the reason for cancellation.
    # Use this value along with the cancellation date to identify possible issues in your app that may lead customers to contact Apple customer support.
    attr_reader :cancellation_reason

    # The time at which the grace period for subscription renewals expires, in a date-time format similar to the ISO 8601.
    # This key is only present for apps that have Billing Grace Period enabled and when the user experiences a billing error at the time of renewal.
    attr_reader :grace_period_expires_at

    # The transaction identifier of the original purchase.
    attr_reader :original_transaction_id

    def initialize(attributes)
      @original_json_data = attributes
      @expiration_intent = Integer(attributes['expiration_intent']) if attributes['expiration_intent']
      @auto_renew_status = Integer(attributes['auto_renew_status']) if attributes['auto_renew_status']
      @auto_renew_product_id = attributes['auto_renew_product_id']

      if attributes['is_in_billing_retry_period']
        @is_in_billing_retry_period = (attributes['is_in_billing_retry_period'] == '1')
      end

      @product_id = attributes['product_id']

      @price_consent_status = Integer(attributes['price_consent_status']) if attributes['price_consent_status']
      @cancellation_reason = Integer(attributes['cancellation_reason']) if attributes['cancellation_reason']
      @grace_period_expires_at = DateTime.parse(attributes['grace_period_expires_date']) if attributes['grace_period_expires_date']
      @original_transaction_id = attributes['original_transaction_id'] if attributes['original_transaction_id']
    end

    def to_hash
      {
        expiration_intent: @expiration_intent,
        auto_renew_status: @auto_renew_status,
        auto_renew_product_id: @auto_renew_product_id,
        is_in_billing_retry_period: @is_in_billing_retry_period,
        product_id: @product_id,
        price_consent_status: @price_consent_status,
        cancellation_reason: @cancellation_reason,
        grace_period_expires_at: (@grace_period_expires_at.httpdate rescue nil),
        original_transaction_id: @original_transaction_id,
      }
    end

    alias_method :to_h, :to_hash

    def to_json
      to_hash.to_json
    end
  end
end
