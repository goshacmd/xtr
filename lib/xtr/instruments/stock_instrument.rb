module Xtr
  module Instruments
    class StockInstrument < CashInstrument
      quantity :integer

      attr_reader :ticker

      def initialize(ticker)
        @ticker = ticker.to_s
      end

      def name
        ticker
      end
    end
  end
end
