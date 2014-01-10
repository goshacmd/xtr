module Xtr
  class Query
    class Ticker < Query
      attr_reader :market_name

      # @param market_name [String]
      def initialize(market_name)
        @market_name = market_name
      end

      def execute(engine)
        engine.market(market_name).ticker
      end
    end
  end
end
