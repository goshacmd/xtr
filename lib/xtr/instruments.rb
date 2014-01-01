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
      end
    end

    class CashInstrument < Instrument
    end
  end
end
