module Xtr
  # A trading engine. Essentially, a container for a supermarket and
  # a balance sheet.
  #
  # @example
  #   engine = Engine.new({ currency: [:BTC, :USD] })
  class Engine
    include Operationable

    attr_reader :supermarket, :balance_sheet, :instruments,
      :instrument_registry, :operation_interface, :query_interface

    delegate :account, to: :balance_sheet
    delegate :market, :markets, to: :supermarket
    delegate :execute, to: :operation_interface
    delegate :query, to: :query_interface

    # Initialize a new +Engine+.
    #
    # @param instruments [Hash{Symbol => Array<Symbol>}] instruments map
    #
    # @see InstrumentRegistry.build_instruments
    def initialize(instruments)
      @supermarket = Supermarket.new(self)
      @balance_sheet = BalanceSheet.new(self)
      @instrument_registry = InstrumentRegistry.new(instruments)
      @operation_interface = OperationInterface.new(self)
      @query_interface = QueryInterface.new(self)

      supermarket.build_markets(instrument_registry.list)
    end

    # Check whether an instrument is supported.
    #
    # @param name [String]
    def supported_instrument?(name)
      instrument_registry.supported?(name)
    end

    # Create a new account and return its ID.
    #
    # @return [String] new account ID
    def new_account
      account.uuid
    end
  end
end
