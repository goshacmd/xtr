require 'xtr'
load 'play/_common.rb'

FileUtils.rm_rf('tmp/demo.journal')

Xtr.logger = Logger.new STDOUT

engine = Xtr::Engine.new do |c|
  c.currency :BTC, :USD
  c.stock :AAPL, :GOOG, :V

  c.stock_markets do |list, _|
    list.product([:USD])
  end

  c.journal :file, "tmp/demo.journal"
end

m = engine.market("BTC/USD")
bs = engine.balance_sheet

a1 = engine.new_account
a2 = engine.new_account

engine.execute :DEPOSIT, a1, "USD", 30_000.00
engine.execute :DEPOSIT, a2, "BTC", 120.00

# depositing stocks? wtf
engine.execute :DEPOSIT, a1, "AAPL", 100

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

engine.execute :CANCEL, a1, engine.query(:OPEN_ORDERS, a1).first[:id]

ob m
b bs

puts "--- #1 balances"
puts engine.query :BALANCES, a1
puts "--- markets"
puts engine.query :MARKETS
puts "--- BTC/USD"
puts engine.query :TICKER, "BTC/USD"
