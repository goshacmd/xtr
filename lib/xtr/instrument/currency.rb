module Xtr
  class Instrument
    # Currency instrument.
    class Currency < CashInstrument
      quantity :decimal

      attr_reader :symbol

      # Initialize a new +Currency+ instrument.
      #
      # @param symbol [String, Symbol] currency code
      def initialize(symbol)
        @symbol = symbol.to_s
      end

      def name
        symbol
      end
    end
  end
end
