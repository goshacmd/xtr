require 'xtr'

Xtr.logger = Logger.new STDOUT
engine = Xtr::Engine.new

m = engine.supermarket[:BTC, :USD]
bs = engine.balance_sheet

a1 = engine.execute :CREATE_ACCOUNT
a2 = engine.execute :CREATE_ACCOUNT

engine.execute :DEPOSIT, a1, :USD, 30_000.00
engine.execute :DEPOSIT, a2, :BTC, 120.00

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
    btc = a.balance(:BTC)
    usd = a.balance(:USD)
    buf << "#{a.uuid}, #{btc}, #{usd}"
  end

  buf << "--"

  all_btc = bs.count_all_in_currency(:BTC)
  all_usd = bs.count_all_in_currency(:USD)

  buf << "Total BTC: #{all_btc.to_f}, USD: #{all_usd.to_f}"

  buf << "--\n"

  puts buf.join "\n"
end

ob m
b bs

ob1 = engine.execute :CREATE_LMT_ORDER, a1, :BTC, :USD, :buy, 575, 20
ob2 = engine.execute :CREATE_LMT_ORDER, a1, :BTC, :USD, :buy, 579, 30

os1 = engine.execute :CREATE_LMT_ORDER, a2, :BTC, :USD, :sell, 581,35
os2 = engine.execute :CREATE_LMT_ORDER, a2, :BTC, :USD, :sell, 585, 40

ob m
b bs

os3 = engine.execute :CREATE_LMT_ORDER, a2, :BTC, :USD, :sell, 575, 10
os4 = engine.execute :CREATE_LMT_ORDER, a2, :BTC, :USD, :sell, 575, 25

ob m
b bs

engine.execute :CANCEL_ORDER, a2, os2

ob m
b bs

engine.execute :CANCEL_ORDER, a1, ob1
engine.execute :CANCEL_ORDER, a1, ob2
engine.execute :CANCEL_ORDER, a2, os2
engine.execute :CANCEL_ORDER, a2, os3
engine.execute :CANCEL_ORDER, a2, os4

ob m
b bs

puts engine.query :BALANCES, a1
puts engine.query :OPEN_ORDERS, a2
