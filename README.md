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

First, you would need to instantiate an engine. Engine is essentially a
container for balance sheet and markets:

```ruby
engine = Xtr::Engine.new
```

The you can get a supermarket and a balance sheet:

```ruby
supermarket = engine.supermarket
balances = engine.balance_sheet
```

### Accounts

To create an account, just call:

```ruby
account = balances.account
```

Accounds can be retrieved by ID:

```ruby
account = balances['0877a894-a597-4fdb-b928-4065c374d419']
```

#### Balance management

Crediting and debiting account balances is easy:

```ruby
# Crediting
account.credit(:USD, 100_000.00)
account.balance(:USD)
# => #<Balance account=123 currency=USD available=100_000.00 reserved=0.00>

# Debiting
account.debit(:USD, 25_000.00)
account.balance(:USD)
# => #<Balance account=123 currency=USD available=75_000.00 reserved=0.00>
```

It's also possible to reserve a specific amount on the balance — and
then either release or debit it:

```ruby
# Make sure to save reservation ID
reservation = account.reserve(:USD, 50_000.00)
account.balance(:USD)
# => #<Balance account=123 currency=USD available=25_000.00 reserved=50_000.00>

# Releasing reserved amount
account.release(:USD, reservation)
account.balance(:USD)
# => #<Balance account=123 currency=USD available=75_000.00 reserved=0.00>

reservation = account.reserve(:USD, 50_000.00)
account.balance(:USD)
# => #<Balance account=123 currency=USD available=25_000.00 reserved=50_000.00>

# Debiting reserved amount
account.debit_reserved(:USD, reservation)
account.balance(:USD)
# => #<Balance account=123 currency=USD available=25_000.00 reserved=0.00>
```

### Markets

A market object can be retrieved from the supermarket by passing a pair
of currency symbols:

```ruby
market = supermarket[:BTC, :USD]
```

### Creating orders

Orders are created on the supermarket (only LMT orders are supported):

```ruby
supermarket.create_order account1, market, :buy, 999.99, 10
supermarket.create_order account2, market, :sell, 1001.00, 20
```

When the orders are matched, balance transfers are performed between the
accounts.

### Orderbook

Orderbook can be queried for the best bid/ask prices:

```ruby
market.orderbook.best_bid # => 999.99
market.orderbook.best_ask # => 1001.00
```

## TODO

* other order types
* other non-currency instruments
* persistence
