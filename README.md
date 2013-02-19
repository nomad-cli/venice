# Venice
**In-App Purchase Receipt Verification**

Venice is a simple gem for verifying Apple In-App Purchase receipts, and retrieving the information associated with receipt data.

From Apple's [In-App Purchase Programming Guide](http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/StoreKitGuide/VerifyingStoreReceipts/VerifyingStoreReceipts.html):

> Your application should perform the additional step of verifying that the receipt you received from Store Kit came from Apple. This is particularly important when your application relies on a separate server to provide subscriptions, services, or downloadable content. Verifying receipts on your server ensures that requests from your application are valid.

> - `quantity`: The number of items purchased. This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
> - `product_id`: The product identifier of the item that was purchased. This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
> - `transaction_id`: The transaction identifier of the item that was purchased. This value corresponds to the transaction’s transactionIdentifier property.
> - `purchase_date`: The date and time this transaction occurred. This value corresponds to the transaction’s transactionDate property.
> - `original_transaction_id`: For a transaction that restores a previous transaction, this holds the original transaction identifier.
> - `original_purchase_date`: For a transaction that restores a previous transaction, this holds the original purchase date.
> - `app_item_id`: A string that the App Store uses to uniquely identify the application that created the payment transaction. If your server supports multiple applications, you can use this value to differentiate between them. Applications that are executing in the sandbox do not yet have an app-item-id assigned to them, so this key is missing from receipts created by the sandbox.
> - `version_external_identifier`: An arbitrary number that uniquely identifies a revision of your application. This key is missing in receipts created by the sandbox.
> - `bid`: The bundle identifier for the application.
> - `bvrs`: A version number for the application.

## Installation

    $ gem install venice

## Usage

```ruby
require 'venice'

data = "(Base64-Encoded Receipt Data)"
if receipt = Venice::Receipt.verify(data)
  p receipt.to_h
end
```

## Comand Line Interface

Venice also comes with the `iap` binary, which provides a convenient way to verify receipts from the command line.


    $ iap verify /path/to/receipt

    +-----------------------------+-------------------------------+
    |                           Receipt                           |
    +-----------------------------+-------------------------------+
    | app_item_id                 |                               |
    | bid                         | com.mindmobapp.MindMob        |
    | bvrs                        | 20120427                      |
    | original_purchase_date      | Mon, 30 Apr 2012 15:05:55 GMT |
    | original_transaction_id     | 1000000046178817              |
    | product_id                  | com.mindmobapp.download       |
    | purchase_date               | Mon, 30 Apr 2012 15:05:55 GMT |
    | quantity                    | 1                             |
    | transaction_id              | 1000000046178817              |
    | version_external_identifier |                               |
    +-----------------------------+-------------------------------+

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Venice is available under the MIT license. See the LICENSE file for more info.
