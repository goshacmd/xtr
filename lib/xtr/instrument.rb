module Xtr
  # Abstract instrument.
  #
  # @abstract Sunclass and implement {#name}.
  #
  # @example
  #   class Currency < Instrument
  #     quantity :decimal
  #     type :currency
  #   end
  class Instrument
    extend ActiveSupport::Autoload
    extend Building

    autoload :Currency
    autoload :Stock

    class << self
      # Build many instruments.
      #
      # @param name [String] instrument name
      # @param args [Array<Array>, Array<Object>] array of instrument argument arrays
      # @return [Array<Instrument>]
      def build_many(name, args)
        klass = lookup(name)
        args.map { |ary| klass.new(*Array(ary)) }
      end

      # Get/set the type of quantity of the instrument.
      #
      # @param type [Symbol] quantity type (+:decimal+ or +:integer+)
      # @return [Symbol]
      def quantity(type = nil)
        @quantity = type if type
        @quantity
      end

      # Get/set the instrument type (name).
      #
      # @param type [Symbol, String] instrument type
      # @return [Symbol, String]
      def type(type = nil)
        @type = type if type
        @type
      end

      # Convert a number to quantity of instrument type.
      #
      # @param number [String, Numeric]
      # @raise [XtrError]
      # @return [Integer, BigDecimal]
      def convert_quantity(number)
        case quantity
        when :decimal
          Util.big_decimal(number)
        when :integer
          number.to_i
        else
          raise XtrError, "No quantity type for instrument '#{type}' defined"
        end
      end
    end

    delegate :convert_quantity, to: :class

    # Get instrument name.
    #
    # @abstract
    def name
      raise NotImplementedError
    end
  end

  # Cash instrument.
  class CashInstrument < Instrument
  end
end
