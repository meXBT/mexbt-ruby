# Mexbt ruby API client

This is a lightweight ruby client for the [meXBT](https://mexbt.com) exchange API. It doesn't try and do anything clever with the JSON response from the API, it simply
returns it as-is.

# Install

If using bundler simply this to your Gemfile:

    gem 'mexbt'

And run `bundle install` of course.

# Ruby version

You need to be using Ruby 2.1 or higher.

# Public API

You can access all the Public API functions with zero configuration. By default they will use the 'BTCMXN' currency pair.

    Mexbt.ticker
    Mexbt.order_book
    Mexbt.trades(start_index: -1, count: 20)
    Mexbt.trades_by_date(from: Date.civil(2014, 11, 1).to_time.to_i, to: Date.today.to_time.to_i)
    Mexbt.simulate_market_order(side: :buy, second_currency: 1000, currency_pair: 'btcmxn') # Simulates a market order, which will estimate how many btc you will receive for 1000 mxn
    Mexbt.simulate_market_order(side: :buy, first_currency: 1, currency_pair: 'btcmxn') # Simulates a market order, which will estimate how many mxn you will spend for 1 btc

If you want to choose another currency pair, you can configure it for all calls:

    Mexbt.configure { |c| c.currency_pair: 'BTCUSD' }

Or alternatively you can set it per call:

    Mexbt.ticker(currency_pair: 'BTCUSD')

# Private API


## Configuration

You need to generate an API key pair at https://mexbt.com/api/keys. However if you want to get started quickly we recommend having a play in the sandbox first, see the 'Sandbox' section below.

    Mexbt.configure do |c|
        mexbt.public_key = "xxx"
        mexbt.private_key = "yyy"
        mexbt.user_id = "email@test.com" # Your registered email address
        mexbt.sandbox = true # Set this to true to use the sandbox
    end

## Order functions

    Mexbt::Orders.create(amount: 0.1, currency_pair: 'btcmxn') # Create a market buy order for 0.1 BTC for Pesos
    Mexbt::Orders.create(amount: 2, side: :sell, currency_pair: 'btcusd') # Create a market order to sell 2 BTC for USD
    Mexbt::Orders.create(amount: 2, price: 1, side: :buy, type: :limit, currency_pair: 'ltcmxn') # Create a limit order to buy 2 LTC for 1 peso
    Mexbt::Orders.cancel(id: 123, currency_pair: 'btcmxn')
    Mexbt::Orders.cancel_all() # Cancel all orders for the default currency pair

## Account functions

    Mexbt::Account.balance
    Mexbt::Account.trades
    Mexbt::Account.orders
    Mexbt::Account.deposit_addresses
    Mexbt::Account.withdraw(amount: 1, currency: :btc, address: 'xxx')  Mexbt::Account.info # Fetches your user info

## Sandbox

It's a good idea to first play with the API in the sandbox, that way you don't need any real money to start trading with the API. Just make sure you configure `sandbox = true`.

You can register a sandbox account at https://sandbox.mexbt.com/en/register. It will ask you to validate your email but there is no need, you can login right away at https://sandbox.mexbt.com/en/login. Now you can setup your API keys at https://sandbox.mexbt.com/en/api/keys.

Your sandbox account will automatically have a bunch of cash to play with.

# API documentation

You can find API docs for the Public API at http://docs.mexbtpublicapi.apiary.io

API docs for the Private API are at http://docs.mexbtprivateapi.apiary.io

There are also docs for the Private API sandbox at http://docs.mexbtprivateapisandbox.apiary.io


# TODO

Mock out web calls with WebMock so that specs don't break everytime sandbox db is cleaned.

