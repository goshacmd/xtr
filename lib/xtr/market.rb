module Xtr
  # Public: A market for a currency pair.
  #
  # Examples
  #
  #   market = Market.new :BTC, :USD
  class Market
    attr_reader :left_currency, :right_currency, :orderbook

    # Public: Initialize a market.
    #
    # left_currency  - The Symbol left currency name.
    # right_currency - The Symbol right currency name.
    def initialize(left_currency, right_currency)
      @left_currency, @right_currency = left_currency, right_currency
      @orderbook = Orderbook.new
    end

    def pair
      [@left_currency, @right_currency].join
    end

    def to_s
      "#<#{self.class.name} #{pair}>"
    end
  end
end
