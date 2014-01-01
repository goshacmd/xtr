# xtr

xtr is a trading engine.

At the moment, xtr only supports LMT orders and everything is stored in
the memory, and not persisted.

## Installation

Add this line to your application's Gemfile:

    gem 'xtr'

And then execute:

    $ bundle

## Getting started

Engine is the core of the trading system. Engine is responsible for executing
user operations and queries.

First, you would need to instantiate an engine and pass it the list of
instruments you want it to support. Instruments are broken down by
category. At the moment, xtr supports currency and stock instruments.

```ruby
instruments = {
  currency: [:BTC, :USD, :EUR, :CNY],
  stock: [:AAPL, :GOOG, :TWTR, :MSFT, :V, :MA]
}

engine = Xtr::Engine.new instruments
```

### Accounts

To create an account, just call:

```ruby
account = engine.execute :CREATE_ACCOUNT
```

It will return account ID.

#### Balance management

Crediting and debiting account balances is easy:

```ruby
# Crediting
engine.execute :DEPOSIT, account, "USD", 100_000.00
engine.execute :BALANCE, account, "USD"
# => { currency: USD, available: 100_000.00, reserved: 0.00 }

# Debiting
engine.execute :WITHDRAW, account, "USD", 25_000.00
engine.execute :BALANCE, account, "USD"
# => { currency: USD, available: 75_000.00, reserved: 0.00 }
```

### Creating orders

Only LMT orders are supported currently.

```ruby
engine.execute :BUY, "BTC/USD", 999.99, 10
engine.execute :SELL, "EUR:AAPL", 600, 25
```

When the orders are matched, balance transfers are performed between the
accounts.

## TODO

* other order types
* other non-currency instruments
* persistence
