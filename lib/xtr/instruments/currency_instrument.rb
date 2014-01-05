module Xtr
  module Instruments
    # Currency instrument.
    class CurrencyInstrument < CashInstrument
      quantity :decimal

      attr_reader :symbol

      # Initialize a new +CurrencyInstrument+.
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
