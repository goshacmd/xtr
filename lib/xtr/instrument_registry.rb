module Xtr
  # Public: A registry of supported instruments.
  class InstrumentRegistry
    class << self
      # Public: Convert a hash list of instrument names to a hash list
      # of instrument instances.
      def build_instruments(list)
        list.map do |category, sublist|
          [category, build_instrument_sublist(category, sublist)]
        end.to_h
      end

      # Public: Given an instrument category and names list, build an
      # array of instrument instances.
      def build_instrument_sublist(category, names)
        case category
        when :currency
          names.map { |name| Instruments::CurrencyInstrument.new(name) }
        when :stock
          names.map { |name| Instruments::StockInstrument.new(name) }
        end
      end
    end

    attr_reader :list

    delegate :[], to: :name_instrument

    # Public: Initialize a registry.
    #
    # list - The Hash list of instruments. Keys are categories
    #        (:currency, :stock), values are arrays of instruments.
    #
    # Examples
    #
    #   ir = InstrumentRegistry.new {
    #     currency: [:USD, :EUR],
    #     stock: [:AAPL, :GOOG]
    #   }
    def initialize(list)
      @list = self.class.build_instruments(list)
    end

    # Public: Get a simple hash of instrument name -> instrument.
    def name_instrument
      @name_instrument ||= Hash[*list.values.flatten.map do |instrument|
        [instrument.name, instrument]
      end.flatten]
    end

    # Public: Get an array of instrument instances.
    def instruments
      name_instrument.values
    end

    # Public: Check whether an instrument is supported.
    def supported?(name)
      name_instrument.has_key?(name)
    end
  end
end
