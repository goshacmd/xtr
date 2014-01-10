module Xtr
  # A trading engine. Essentially, a container for a supermarket and
  # a balance sheet.
  #
  # @example
  #   engine = Engine.new do |c|
  #     c.currency :BTC, :USD
  #   end
  class Engine
    extend ActiveSupport::Autoload

    autoload :Config

    attr_reader :supermarket, :balance_sheet, :instruments,
      :instrument_registry, :operation_interface, :query_interface, :journal

    # @!method account
    # @see BalanceSheet#account
    delegate :account, to: :balance_sheet
    # @!method market
    # @see Supermarket#market
    # @!method markets
    # @see Supermarket#markets
    delegate :market, :markets, to: :supermarket
    # @!method execute
    # @see Operationable#execute
    delegate :execute, to: :operation_interface
    # @!method query
    # @see Queryable#query
    delegate :query, to: :query_interface

    # Initialize a new +Engine+.
    #
    # @yieldparam [Config] config engine configuration
    # @see InstrumentRegistry.build_instruments
    def initialize
      @supermarket = Supermarket.new(self)
      @balance_sheet = BalanceSheet.new(self)

      config = Config.new
      yield config if block_given?

      @instrument_registry = InstrumentRegistry.new(config.instruments)
      @journal = Journal.build(*config.journal)
      @operation_interface = OperationInterface.new(self, @journal)
      @query_interface = QueryInterface.new(self)

      supermarket.build_markets(instrument_registry, config.markets)
    end

    # Replay operations from journal.
    #
    # @return [void]
    def replay
      journal.replay(operation_interface)
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

    def inspect
      "#<#{self.class.name}>"
    end
  end
end
