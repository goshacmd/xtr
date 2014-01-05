module Xtr
  module Instruments
    # Stock instrument.
    class StockInstrument < CashInstrument
      quantity :integer

      attr_reader :ticker

      # Initialize a new +StockInstrument+.
      #
      # @param ticker [String, Symbol] stock ticker
      def initialize(ticker)
        @ticker = ticker.to_s
      end

      def name
        ticker
      end
    end
  end
end
