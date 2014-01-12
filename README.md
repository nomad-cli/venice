![Venice](https://raw.github.com/mattt/nomad-cli.com/assets/venice-banner.png)

Venice is a simple gem for verifying Apple In-App Purchase receipts, and retrieving the information associated with receipt data.

There are two reasons why you should verify in-app purchase receipts on the server: First, it allows you to keep your own records of past purchases, which is useful for up-to-the-minute metrics and historical analysis. Second, server-side verification over SSL is the most reliable way to determine the authenticity of purchasing records.

See Apple's [In-App Purchase Programming Guide](http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/StoreKitGuide/VerifyingStoreReceipts/VerifyingStoreReceipts.html) for additional information.

> Venice is named for [Venice, Italy](http://en.wikipedia.org/wiki/Venice,_Italy)—or more specifically, Shakespeare's [_The Merchant of Venice_](http://en.wikipedia.org/wiki/The_Merchant_of_Venice).
> It's part of a series of world-class command-line utilities for iOS development, which includes [Cupertino](https://github.com/mattt/cupertino) (Apple Dev Center management), [Shenzhen](https://github.com/mattt/shenzhen) (Building & Distribution), [Houston](https://github.com/mattt/houston) (Push Notifications), and [Dubai](https://github.com/mattt/dubai) (Passbook pass generation).

## Installation

    $ gem install venice

## Usage

```ruby
require 'venice'

data = "(Base64-Encoded Receipt Data)"
if receipt = Venice::Receipt.verify(data, {:shared_secret => "mysecret"})
  p receipt.to_h
end
```

## Command Line Interface

Venice also comes with the `iap` binary, which provides a convenient way to verify receipts from the command line.


    $ iap verify /path/to/receipt

    +-----------------------------+-------------------------------+
    |                           Receipt                           |
    +-----------------------------+-------------------------------+
    | app_item_id                 |                               |
    | bid                         | com.foo.bar                   |
    | bvrs                        | 20120427                      |
    | original_purchase_date      | Sun, 01 Jan 2013 12:00:00 GMT |
    | original_transaction_id     | 1000000000000001              |
    | product_id                  | com.example.product           |
    | purchase_date               | Sun, 01 Jan 2013 12:00:00 GMT |
    | quantity                    | 1                             |
    | transaction_id              | 1000000000000001              |
    | version_external_identifier |                               |
    +-----------------------------+-------------------------------+

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Venice is available under the MIT license. See the LICENSE file for more info.
