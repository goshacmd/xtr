module Xtr
  module Instruments
    extend ActiveSupport::Autoload

    autoload :CurrencyInstrument
    autoload :StockInstrument

    # Public: Abstract instrument.
    #
    # Examples
    #
    #   class CurrencyInstrument < Instrument
    #     quantity :decimal
    #     type :currency
    #   end
    class Instrument
      class << self
        # Public: Get/set the type of quantity of the instrument.
        #
        # type - The Symbol quantity type. Possible values: :decimal, :integer.
        def quantity(type = nil)
          @quantity = type if type
          @quantity
        end

        # Public: Get/set the instrument type (name).
        def type(type = nil)
          @type = type if type
          @type
        end

        # Public: Convert a number to quantity of instrument type.
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

      # Public: Get instrument name.
      def name
        raise NotImplementedError
      end
    end

    class CashInstrument < Instrument
    end
  end
end
