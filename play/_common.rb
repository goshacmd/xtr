# Print orderbook
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

# Print complete balance sheet
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

# Print balance sheet summary
def s(bs)
  buf = []
  buf << ""
  buf << "---"

  all = bs.count_all.map { |k, v| "#{k}: #{v.to_f}" }
  buf << "Total: #{all.join(', ')}"

  buf << "---\n"

  puts buf.join "\n"
end
