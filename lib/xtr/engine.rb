module Xtr
  # Public: A trading engine. Essentially, a container for a supermarket and
  # a balance sheet.
  class Engine
    include Operationable

    attr_reader :supermarket, :balance_sheet, :instruments,
      :instrument_registry, :operation_interface

    delegate :account, to: :balance_sheet
    delegate :market, :markets, to: :supermarket
    delegate :execute, :query, to: :operation_interface

    def initialize(instruments)
      @supermarket = Supermarket.new(self)
      @balance_sheet = BalanceSheet.new(self)
      @instrument_registry = InstrumentRegistry.new(instruments)
      @operation_interface = OperationInterface.new(self)

      supermarket.build_markets(instrument_registry.list)
    end

    # Public: Check whether an instrument is supported.
    def supported_instrument?(name)
      instrument_registry.supported?(name)
    end
  end
end
