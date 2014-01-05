require 'xtr'

Xtr.logger = Logger.new STDOUT

engine = Xtr::Engine.new({
  currency: [:BTC, :USD],
  stock: [:AAPL, :GOOG, :V]
})

m = engine.market("BTC/USD")
bs = engine.balance_sheet

a1 = engine.new_account
a2 = engine.new_account

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
  o.asks.reverse_each { |_, a| buf << a }
  buf << "---"
  o.bids.reverse_each { |_, a| buf << a }
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

  all = bs.count_all.map { |k, v| "#{k}: #{v.to_f}" }
  buf << "Total: #{all.join(', ')}"

  buf << "---\n"

  puts buf.join "\n"
end

ob m
b bs

engine.execute :BUY, a1, "BTC/USD", 575, 20
engine.execute :BUY, a1, "BTC/USD", 579, 30

engine.execute :SELL, a2, "BTC/USD", 581, 35
engine.execute :SELL, a2, "BTC/USD", 585, 40

engine.execute :SELL, a1, "USD:AAPL", 710, 10

ob m
b bs

engine.execute :SELL, a2, "BTC/USD", 575, 10
engine.execute :SELL, a2, "BTC/USD", 575, 25

engine.execute :BUY, a2, "USD:AAPL", 750, 10

ob m
b bs

[a1, a2].each do |account|
  engine.query(:OPEN_ORDERS, account).each do |order|
    engine.execute :CANCEL, account, order[:id]
  end
end

ob m
b bs

puts "--- #1 balances"
puts engine.query :BALANCES, a1
puts "--- markets"
puts engine.query :MARKETS
puts "--- BTC/USD"
puts engine.query :TICKER, "BTC/USD"
