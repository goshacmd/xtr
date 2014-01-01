require 'xtr'

#Xtr.logger = Logger.new STDOUT

instruments = {
  currency: [:BTC, :USD]
}

engine = Xtr::Engine.new instruments

m = engine.market("BTC/USD")
bs = engine.balance_sheet

accounts = (0..10_000).map { engine.execute :CREATE_ACCOUNT }

accounts.each do |account|
  engine.execute :DEPOSIT, account, "BTC", rand(0..1_000)
  engine.execute :DEPOSIT, account, "USD", rand(0..1_000_000) * rand(0..3)
end

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
  buf << "---"

  all_btc = bs.count_all_in_instrument("BTC")
  all_usd = bs.count_all_in_instrument("USD")

  buf << "Total BTC: #{all_btc.to_f}, USD: #{all_usd.to_f}"

  buf << "---\n"

  puts buf.join "\n"
end

b bs

100_000.times do |i|
  account = accounts.sample
  balances = engine.query :BALANCES, account
  orders = engine.query :OPEN_ORDERS, account

  operations = [:BUY, :SELL]
  operations << :CANCEL unless orders.empty?

  operation = operations.sample

  if [:BUY, :SELL].include? operation
    buy = operation == :BUY
    currency = buy ? "USD" : "BTC"
    in_currency = Xtr::Util.big_decimal balances.find { |b| b[:instrument] == currency }[:available]
    to_trade = rand(0..in_currency/3).to_f
    price = rand(700..900).to_f

    amount = buy ? to_trade : to_trade / price

    engine.execute operation, account, "BTC/USD", price, amount unless amount == 0
  else
    engine.execute operation, account, orders.sample[:id]
  end
end

b bs
ob m
