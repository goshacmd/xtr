module Xtr
  class Instrument
    # Resource instrument.
    class Resource < CashInstrument
      quantity :decimal

      attr_reader :ticker

      # Initialize a new +Resource+ instrument.
      #
      # @param ticker [String, Symbol] resource ticker
      def initialize(ticker)
        @ticker = ticker.to_s
      end

      def name
        ticker
      end
    end
  end
end
