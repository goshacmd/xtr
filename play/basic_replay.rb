require 'xtr'
load 'play/_common.rb'

Xtr.logger = Logger.new STDOUT

engine = Xtr::Engine.new do |c|
  c.currency :BTC, :USD
  c.stock :AAPL, :GOOG, :V
  c.journal :file, "tmp/demo.journal"
end

m = engine.market("BTC/USD")
bs = engine.balance_sheet

engine.replay

ob m
b bs

puts "--- markets"
puts engine.query :MARKETS
puts "--- BTC/USD"
puts engine.query :TICKER, "BTC/USD"
