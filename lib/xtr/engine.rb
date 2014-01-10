module Xtr
  # A trading engine. Essentially, a container for a supermarket and
  # a balance sheet.
  #
  # @example
  #   engine = Engine.new do |c|
  #     c.currency :BTC, :USD
  #   end
  class Engine
    include Operationable

    attr_reader :supermarket, :balance_sheet, :instruments,
      :instrument_registry, :operation_interface, :query_interface, :journal

    delegate :account, to: :balance_sheet
    delegate :market, :markets, to: :supermarket
    delegate :execute, to: :operation_interface
    delegate :query, to: :query_interface

    # Engine configuration.
    class Config
      # Set journal.
      #
      # @param args [Array] journal description.
      # First item is journal type, the rest is just passed to journal initializer
      def journal(*args)
        @journal ||= [:dummy]
        @journal = args unless args.empty?
        @journal
      end

      # Set instruments.
      #
      # @param desc [Hash{Symbol => Array<Symbol>}] instruments map
      #
      # @see InstrumentRegistry.build_instruments
      def instruments(desc = nil)
        @instruments ||= {}
        @instruments = desc if desc
        @instruments
      end

      # Set currency instruments.
      #
      # @param list [Array<Symbol>] list of currency instrument names
      def currency(*list)
        @instruments ||= {}
        @instruments[:currency] = list
      end

      # Set stock instruments.
      #
      # @param list [Array<Symbol>] list of stock instrument names
      def stock(*list)
        @instruments ||= {}
        @instruments[:stock] = list
      end

      # Set markets.
      #
      # @param desc [Hash{Symbol => Proc}]
      #
      # @see Supermarket.build_markets
      def markets(desc = nil)
        @markets ||= {
          currency: ->(list, _) { list.combination(2) },
          stock: ->(list, inst) { list.product(inst[:currency]) }
        }
        @markets = desc if desc
        @markets
      end

      # Set currency market generator proc.
      def currency_markets(&block)
        markets
        @markets[:currency] = block
      end

      # Set stock market generator proc.
      def stock_markets(&block)
        markets
        @markets[:stock] = block
      end
    end

    # Initialize a new +Engine+.
    #
    # @yieldparam [Config] config engine configuration
    #
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
