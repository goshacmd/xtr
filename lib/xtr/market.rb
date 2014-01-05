module Xtr
  # A market for an instrument pair.
  #
  # @example
  #   btcusd = Market.new :currency, BTC, USD
  #   aapl = Market.new :stock, AAPL, USD
  class Market
    extend ActiveSupport::Autoload

    autoload :Execution
    autoload :Limit
    autoload :Order
    autoload :Orderbook
    autoload :Trees

    attr_reader :type, :left, :right, :orderbook

    delegate :bids, :asks, :best_bid, :best_ask, :last_price,
      :add_order, :cancel_order, to: :orderbook

    delegate :convert_quantity, to: :left

    # Initialize a new +Market+.
    #
    # @param type [Symbol] market type (+:currency+ or +:stock+)
    # @param left [Instruments::Instrument] left instrument
    # @param right [Instruments::Instrument] right instrument
    def initialize(type, left, right)
      @type = type
      @left, @right = left, right
      @orderbook = Orderbook.new
    end

    # Get ticker info.
    #
    # @return [Hash]
    def ticker
      bid = best_bid
      ask = best_ask
      spread = bid && ask ? ask - bid : nil

      {
        bid: Util.number_to_string(bid),
        ask: Util.number_to_string(ask),
        spread: Util.number_to_string(spread),
        last_price: Util.number_to_string(last_price)
      }
    end

    # Get a string code of the market.
    #
    # @return [String]
    def pair
      case type
      when :currency
        [@left.name, @right.name].join('/') # => BTC/USD
      when :stock
        [@right.name, @left.name].join(':') # => USD:AAPL
      end
    end

    def as_json
      { name: pair, type: type }
    end

    def to_s
      pair
    end

    def inspect
      "#<#{self.class.name} #{pair}>"
    end
  end
end
