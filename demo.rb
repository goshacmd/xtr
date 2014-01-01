require 'xtr'

Xtr.logger = Logger.new STDOUT

instruments = {
  currency: [:BTC, :USD].map { |c| Xtr::Instruments::CurrencyInstrument.new(c) },
  stock: [:AAPL, :GOOG, :V].map { |s| Xtr::Instruments::StockInstrument.new(s) }
}

engine = Xtr::Engine.new instruments

m = engine.market("BTC/USD")
bs = engine.balance_sheet

a1 = engine.execute :CREATE_ACCOUNT
a2 = engine.execute :CREATE_ACCOUNT

engine.execute :DEPOSIT, a1, "USD", 30_000.00
engine.execute :DEPOSIT, a2, "BTC", 120.00

# depositing stocks? wtf
engine.execute :DEPOSIT, a1, "AAPL", 100

def ob(m)
  o = m.orderbook

  buf = []
  buf << ""
  buf << "Orderbook:"
  buf << "---"
  o.asks.to_a.reverse.each { |_, a| buf << "#{a.price.to_f} x #{a.size.to_f}" }
  buf << "---"
  o.bids.to_a.reverse.each { |_, a| buf << "#{a.price.to_f} x #{a.size.to_f}" }
  buf << "---\n"

  puts buf.join "\n"
end

def b(bs)
  buf = []
  buf << ""
  buf << "Balance sheet:"
  buf << "---"

  bs.accounts.each do |_, a|
    buf << a
  end

  buf << "---"

  all_btc = bs.count_all_in_currency("BTC")
  all_usd = bs.count_all_in_currency("USD")

  buf << "Total BTC: #{all_btc.to_f}, USD: #{all_usd.to_f}"

  buf << "---\n"

  puts buf.join "\n"
end

ob m
b bs

ob1 = engine.execute :BUY, a1, "BTC/USD", 575, 20
ob2 = engine.execute :BUY, a1, "BTC/USD", 579, 30

os1 = engine.execute :SELL, a2, "BTC/USD", 581, 35
os2 = engine.execute :SELL, a2, "BTC/USD", 585, 40

engine.execute :SELL, a1, "USD:AAPL", 710, 10

ob m
b bs

os3 = engine.execute :SELL, a2, "BTC/USD", 575, 10
os4 = engine.execute :SELL, a2, "BTC/USD", 575, 25

engine.execute :BUY, a2, "USD:AAPL", 750, 10

ob m
b bs

engine.execute :CANCEL, a2, os2

ob m
b bs

[a1, a2].each do |account|
  engine.query(:OPEN_ORDERS, account).each do |order|
    engine.execute :CANCEL, account, order[:id]
  end
end

ob m
b bs

puts engine.query :BALANCES, a1
puts engine.query :OPEN_ORDERS, a2
puts engine.query :TICKER, "BTC/USD"
