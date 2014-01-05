module Xtr
  # An account
  #
  # @example
  #   acc = Account.new(engine)
  #   acc.credit(:USD, 100.00)
  #   acc.balance(:USD) # => #<Balance account=123 instrument=USD available=100.00 reserved=0.00>
  class Account
    attr_reader :engine, :open_orders, :uuid

    # Initialize a new +Account+.
    #
    # @param engine [Engine]
    # @param uuid [String] account UUID
    def initialize(engine, uuid = Util.uuid)
      @engine = engine
      @open_orders = []
      @balances = BalanceCollection.new(self)

      @uuid = uuid
    end

    # Get an account's balance in specific instrument.
    #
    # @param instrument [Symbol] instrument code
    def balance(instrument)
      @balances[instrument]
    end
    alias [] balance

    # Delegate balance-related methods to balance for appropriate instrument.
    #
    # @!method credit
    #   @see CashBalance#credit
    #   @example
    #     account.credit(USD, 100.00)
    #
    # @!method debit
    #   @see CashBalance#debit
    #   @example
    #     account.debit(USD, 100.00)
    #
    # @!method reserve
    #   @see CashBalance#reserve
    #   @example
    #     account.resevre(USD, 50.00)
    #
    # @!method release
    #   @see CashBalance#release
    #   @example
    #     account.release(USD, 'reserve-id')
    #
    # @!method debit_reserved
    #   @see CashBalance#debit_reserved
    #   @example
    #     account.debit_reserved(USD, 'reserve-id')
    delegate :credit, :debit, :reserve, :release, :debit_reserved,
      to: 'balance(args.shift)'

    def to_s
      "#{uuid} - #{@balances.to_a.join(', ')}"
    end

    def inspect
      "#<#{self.class.name} id=#{uuid}>"
    end
  end
end
