module Xtr
  # Public: A collection of markets.
  class Supermarket
    attr_reader :engine, :markets

    # Public: Initialize a supermarket.
    def initialize(engine)
      @engine = engine
      @markets = {}
    end

    # Public: Build markets for instruments.
    #
    # instruments - The Hash of instruments. Keys are categories (:currency, :stock),
    #               values are arrays of instruments.
    def build_markets(instruments)
      @markets = instruments.map do |(category, list)|
        case category
        when :currency
          list.combination(2).map do |left, right|
            Market.new(:currency, left, right)
          end
        when :stock
          list.product(instruments[:currency]).map do |stock, currency|
            Market.new(:stock, stock, currency)
          end
        end
      end.flatten.map { |m| [m.pair, m] }.to_h
    end

    # Public: Get a market for the instrument pair.
    def market(name)
      @markets[name]
    end
    alias_method :[], :market

    # Public: Route an order to the appropriate market.
    def route_order(order)
      order.market.add_order(order)
    end

    # Public: Create and route an order.
    def create_order(*args)
      order = Market::Order.new(*args)
      route_order(order)
      order
    end

    # Public: Cancel an order.
    def cancel_order(order)
      order.market.cancel_order(order)
    end
  end
end
