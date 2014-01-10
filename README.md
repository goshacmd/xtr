# xtr

xtr is a trading engine. xtr is an experimental development.

At the moment, xtr only supports cash instruments trading, LIMIT orders, and
everything is stored in the memory, and not persisted.

[Documentation](http://rubydoc.info/github/goshakkk/xtr/master/frames)

## Concepts

**Engine** is the core of the trading system. Engine is responsible for executing
user operations and queries.

**Instrument** is a tradeable asset. It can be stock or currency.

xtr identifies instruments simply by their codes.

**Market** is a place where one kind of asset is traded for another.
For example, a place where you can trade EUR for CNY or AAPL for USD is
a market.

There are two types of markets and they have different schemes of
their identifiers.

Currency markets are identified by a currency pair (e.g. BTC/USD,
BTC/EUR).

Stock markets are identified by a stock ticker prepended with currency
code (e.g. USD:AAPL, EUR:GOOG, BTC:V).

**Account** is a collection of balances in different instruments. It is
identified by a UUID string returned from `engine.account`.

Each balance has available and reserved amounts.

## Getting started

To get started, you would need to instantiate an engine and specify
instruments you want it to support. Instruments are broken down by
category. At the moment, xtr supports currency and stock instruments.

```ruby
engine = Xtr::Engine.new do |c|
  c.currency :BTC, :USD, :EUR
  c.stock :AAPL, :GOOG, :TWTR, :V
end
```

Engine will then create *markets* for described instruments. By default,
it will create a market for each pair of currencies and a market for
each stock in every supported currency.

In this example, the following markets will be generated:

* currency
  * BTC/USD
  * BTC/EUR
  * USD/EUR

* stock
  * BTC:AAPL
  * USD:AAPL
  * EUR:AAPL
  * BTC:GOOG
  * USD:GOOG
  * EUR:GOOG
  * BTC:TWTR
  * USD:TWTR
  * EUR:TWTR
  * BTC:V
  * USD:V
  * EUR:V

### Markets

#### Listing available markets

```ruby
engine.query :MARKETS
# => [
#      { name: "BTC/USD", type: :currency },
#      { name: "USD:AAPL", type: :stock }
#    ]
```

#### Querying tickers

To get a ticker for a market, simply issue a TICKER query with market
code as an argument:

```ruby
engine.query :TICKER, 'EUR:GOOG'
# => { bid: 499.90, ask: 500.30, last_price: 500.10 }
```

### Accounts

To create an account, just call:

```ruby
account = engine.new_account
```

It will return account ID. You will need it to manage balances and
orders.

#### Balance management

Crediting and debiting account balances is easy — just pass account ID,
instrument name and amount:

```ruby
# Crediting
engine.execute :DEPOSIT, account, "USD", 100_000.00
engine.query :BALANCE, account, "USD"
# => { currency: USD, available: 100_000.00, reserved: 0.00 }

# Debiting
engine.execute :WITHDRAW, account, "USD", 25_000.00
engine.query :BALANCE, account, "USD"
# => { currency: USD, available: 75_000.00, reserved: 0.00 }
```

#### Listing balances

```ruby
engine.query :BALANCES, account
# => [{
#       instrument: 'AAPL',
#       available: 10,
#       reserved: 5
#    }]
```

### Orders

#### Creating orders

To create an order, execute BUY/SELL operation with account ID, market
code, price, and quantity as arguments:

*(Only LMT orders are supported currently.)*

```ruby
engine.execute :BUY, account, "BTC/USD", 999.99, 10
engine.execute :SELL, account, "EUR:AAPL", 600, 25
```

When the orders are matched, balance transfers are performed between the
accounts.

#### Canceling orders

To cancel an order, execute CANCEL operation, passing account ID and
order ID:

```ruby
engine.execute :CANCEL, account, order
```

#### Getting open orders

You can query open orders for a particular account this way:

```ruby
engine.query :OPEN_ORDERS, account
# => [{
#       id: 'uuid',
#       market: 'BTC/USD',
#       direction: :buy,
#       price: 999.99,
#       quantity: 10,
#       remainder: 5,
#       status: :partially_filled,
#       created_at: Time
#    }]
```


## TODO

* other order types (market, stop-loss, take-profit, fill-or-kill)
* margin trading
* derivative instruments (CFDs, futures, options)
* event sourcing & persistence
* snapshots
