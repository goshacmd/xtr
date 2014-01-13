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
    # Generators are procs which take list of instruments of given category
    # and a hash of all instruments. Generators should return an array of
    # +[left_instrument, right_instrument]+ pairs.
    #
    # @param instruments [InstrumentRegistry]
    # @param generators [Hash{Symbol => Proc}]
    # @return [Hash{String => Market}]
    def build_markets(instruments, generators)
      inst = instruments.list
      @markets = inst.map do |(category, list)|
        generator = generators[category]
        generator.call(list, inst).map do |left, right|
          left = instruments[left]
          right = instruments[right]
          Market.new(category, left, right)
        end
      end.flatten.map { |m| [m.name, m] }.to_h
    end

    # Get a market for the instrument pair.
    #
    # @param name [String]
    # @return [Market]
    def market(name)
      @markets[name]
    end
    alias_method :[], :market

    # Route an order to the appropriate market.
    #
    # @param order [Market::Order]
    # @return [void]
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
    # @return [void]
    def cancel_order(order)
      order.market.cancel_order(order)
    end
  end
end
