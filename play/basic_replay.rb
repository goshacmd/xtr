require 'xtr'
load 'play/_common.rb'

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

engine.replay

a1, a2 = bs.accounts.keys

ob m
b bs

puts "--- #1 balances"
puts engine.query :BALANCES, a1
puts "--- markets"
puts engine.query :MARKETS
puts "--- BTC/USD"
puts engine.query :TICKER, "BTC/USD"
