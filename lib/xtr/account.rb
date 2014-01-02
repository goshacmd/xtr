module Xtr
  # Public: An account.
  #
  # Examples
  #
  #   acc = Account.new
  #   acc.credit(engine, :USD, 100.00)
  #   acc.balance(:USD) # => #<Balance account=123 instrument=USD available=100.00 reserved=0.00>
  class Account
    attr_reader :engine, :open_orders, :uuid

    # Public: Initialize an account.
    #
    # engine - The Engine instance.
    # uuid   - The UUID string. Default: auto-generate.
    def initialize(engine, uuid = Util.uuid)
      @engine = engine
      @open_orders = []
      @balances = BalanceCollection.new(self)

      @uuid = uuid
    end

    # Public: Get an account's balance in specific instrument.
    #
    # instrument - The Symbol instrument code.
    def balance(instrument)
      @balances[instrument]
    end
    alias [] balance

    # Delegate balance-related methods to balance for appropriate instrument.
    #
    # Examples
    #
    #   account.credit(USD, 100.00)
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
