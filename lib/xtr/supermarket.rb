module Xtr
  # A collection of markets.
  class Supermarket
    attr_reader :engine, :markets

    # Initialize a new +Supermarket+.
    #
    # @param engine [Engine]
    def initialize(engine)
      @engine = engine
      @markets = {}
    end

    # Build markets for instruments.
    #
    # @param instruments [Hash{Symbol => Array<Instruments::Instrument>}]
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

    # Get a market for the instrument pair.
    #
    # @param name [String]
    #
    # @return [Market]
    def market(name)
      @markets[name]
    end
    alias_method :[], :market

    # Route an order to the appropriate market.
    #
    # @param order [Market::Order]
    def route_order(order)
      order.market.add_order(order)
    end

    # Create and route an order.
    #
    # @see Market::Order#initialize
    def create_order(*args)
      order = Market::Order.new(*args)
      route_order(order)
      order
    end

    # Cancel an order.
    #
    # @param order [Market::Order]
    def cancel_order(order)
      order.market.cancel_order(order)
    end
  end
end
