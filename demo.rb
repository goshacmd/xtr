require 'xtr'

Xtr.logger = Logger.new STDOUT
engine = Xtr::Engine.new
sm = engine.supermarket
bs = engine.balance_sheet

m = sm[:BTC, :USD]
a1 = bs[]
a2 = bs[]

a1.credit(:USD, 30_000.00)
a2.credit(:BTC, 120.00)

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

sm.create_order a1, m, :buy, 575, 20
sm.create_order a1, m, :buy, 579, 30

sm.create_order a2, m, :sell, 581, 35
sm.create_order a2, m, :sell, 585, 40

ob m
b bs

sm.create_order a2, m, :sell, 575, 10
sm.create_order a2, m, :sell, 575, 25

ob m
b bs
