module Xtr
  # Public: A collection of markets.
  class Supermarket
    attr_reader :markets

    # Public: Initialize a supermarket.
    def initialize
      @markets = {}
    end

    # Public: Get a market for the currency pair.
    def market(base_currency, quoted_currency)
      pair = [base_currency, quoted_currency].join
      @markets[pair] ||= Market.new(base_currency, quoted_currency)
    end
    alias_method :[], :market

    # Public: Route an order to the appropriate market.
    def route_order(order)
      order.market.orderbook.add_order(order)
    end

    # Public: Create and route an order.
    def create_order(*args)
      order = Order.new(*args)
      route_order(order)
      order
    end
  end
end
