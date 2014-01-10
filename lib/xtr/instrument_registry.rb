module Xtr
  # A registry of supported instruments.
  class InstrumentRegistry
    class << self
      # Convert a hash list of instrument names to a hash list
      # of instrument instances.
      #
      # @param list [Hash{Symbol => Array<Symbol>}]
      # @return [Hash{Symbol => Array<Instrument>}]
      def build_instruments(list)
        list.map do |category, sublist|
          [category, build_instrument_sublist(category, sublist)]
        end.to_h
      end

      # Given an instrument category and names list, build an
      # array of instrument instances.
      #
      # @param category [Symbol] category name (+:currency+ or +:stock+)
      # @param names [Array<Symbol>] list of instrument names
      # @return [Array<Instrument>]
      def build_instrument_sublist(category, names)
        instrument = Instrument.for_type(category)
        names.map { |name| instrument.new(name) }
      end
    end

    attr_reader :list

    delegate :[], to: :name_instrument

    # Initialize a new +InstrumentRegistry+.
    #
    # @param list [Hash{Symbol => Array<Symbol>}] map of instruments.
    #
    # @example
    #   ir = InstrumentRegistry.new({
    #     currency: [:USD, :EUR],
    #     stock: [:AAPL, :GOOG]
    #   })
    def initialize(list)
      @list = self.class.build_instruments(list)
    end

    # Get a simple hash of instrument name -> instrument.
    #
    # @return [Hash{String => Instrument}]
    def name_instrument
      @name_instrument ||= list.values.flatten.map do |instrument|
        [instrument.name, instrument]
      end.to_h
    end

    # Get an array of instrument names.
    #
    # @return [Array<String>]
    def names
      name_instrument.keys
    end

    # Get an array of instrument instances.
    #
    # @return [Array<Instrument>]
    def instruments
      name_instrument.values
    end

    # Get instrument by name.
    #
    # @return [Instrument]
    def [](name)
      Instrument === name ? name : name_instrument[name.to_s]
    end

    # Check whether an instrument is supported.
    #
    # @param name [String]
    def supported?(name)
      name_instrument.has_key?(name)
    end
  end
end
