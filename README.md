# Venice
**In-App Purchase Receipt Verification**

Venice is a simple gem for verifying Apple In-App Purchase receipts, and retrieving the information associated with receipt data.

There are two reasons why you should verify in-app purchase receipts on the server: First, it allows you to keep your own records of past purchases, which is useful for up-to-the-minute metrics and historical analysis. Second, server-side verification over SSL is the most reliable way to determine the authenticity of purchasing records.

See Apple's [In-App Purchase Programming Guide](http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/StoreKitGuide/VerifyingStoreReceipts/VerifyingStoreReceipts.html) for additional information.

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
