module Xtr
  class Instrument
    # Stock instrument.
    class Stock < CashInstrument
      quantity :integer

      attr_reader :ticker

      # Initialize a new +Stock+ instrument.
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
