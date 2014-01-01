module Xtr
  module Instruments
    # Public: Currency instrument.
    class CurrencyInstrument < CashInstrument
      quantity :decimal

      attr_reader :symbol

      def initialize(symbol)
        @symbol = symbol.to_s
      end

      def name
        symbol
      end
    end
  end
end
