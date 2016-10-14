![Venice](https://raw.github.com/nomad/nomad.github.io/assets/venice-banner.png)

Venice is a simple gem for verifying Apple In-App Purchase receipts, and retrieving the information associated with receipt data.

There are two reasons why you should verify in-app purchase receipts on the server: First, it allows you to keep your own records of past purchases, which is useful for up-to-the-minute metrics and historical analysis. Second, server-side verification over SSL is the most reliable way to determine the authenticity of purchasing records.

See Apple's [Receipt Validation Programming Guide](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Introduction.html) for additional information.

> Venice is named for [Venice, Italy](http://en.wikipedia.org/wiki/Venice,_Italy)—or more specifically, Shakespeare's [_The Merchant of Venice_](http://en.wikipedia.org/wiki/The_Merchant_of_Venice).
> It's part of a series of world-class command-line utilities for iOS development, which includes [Cupertino](https://github.com/mattt/cupertino) (Apple Dev Center management), [Shenzhen](https://github.com/mattt/shenzhen) (Building & Distribution), [Houston](https://github.com/mattt/houston) (Push Notifications), [Dubai](https://github.com/mattt/dubai) (Passbook pass generation), and [Nashville](https://github.com/nomad/nashville) (iTunes Store API).

## Installation

    $ gem install venice

## Usage

### Basic

```ruby
require 'venice'

data = "(Base64-Encoded Receipt Data)"
if receipt = Venice::Receipt.verify(data)
  p receipt.to_h

  # You can refer an original JSON response via a Receipt instance.
  case receipt.original_json_response['status'].to_i
    when 0     then foo
    when 21006 then bar
  end
end
```

### For Auto-Renewable

```ruby
require 'venice'

data = "(Base64-Encoded Receipt Data)"

# You must pass shared secret when verification on Auto-Renewable
opts = {
  shared_secret: 'your key'
}
if receipt = Venice::Receipt.verify(data, opts)
  # Renewed receipts are added into `latest_receipt_info` array.
  p receipt.latest_receipt_info.map(&:expires_at)
  # => [2016-05-19 20:35:59 +0000, 2016-06-18 20:35:59 +0000, 2016-07-18 20:35:59 +0000]
end
```

## Command Line Interface

Venice also comes with the `iap` binary, which provides a convenient way to verify receipts from the command line.


    $ iap verify /path/to/receipt

    +--------------------------------+------------------------------------+
    |                               Receipt                               |
    +--------------------------------+------------------------------------+
    | adam_id                        | 664753504                          |
    | application_version            | 123                                |
    | bundle_id                      | com.example.product                |
    | download_id                    | 30000000000005                     |
    | expires_at                     |                                    |
    | latest_receipt                 |                                    |
    | original_application_version   | 123                                |
    | original_purchase_date         | Fri, 07 Mar 2014 20:59:24 GMT      |
    | receipt_type                   | Production                         |
    | requested_at                   | Mon, 23 Jun 2014 17:59:38 GMT      |
    +--------------------------------+------------------------------------+
    | in_app                         | 1                                  |
    |  - app_item_id                 |                                    |
    |  - cancellation_at             |                                    |
    |  - expires_at                  |                                    |
    |  - original_purchase_date      |                                    |
    |  - original_transaction_id     | 1000000000000001                   |
    |  - product_id                  | com.example.product                |
    |  - purchase_date               |                                    |
    |  - quantity                    | 1                                  |
    |  - transaction_id              | 1000000000000001                   |
    |  - version_external_identifier |                                    |
    +--------------------------------+------------------------------------+


## Creator

Mattt Thompson ([@mattt](https://twitter.com/mattt))

## License

Venice is available under the MIT license. See the LICENSE file for more info.
