module Xtr
  # A balance sheet of all accounts.
  class BalanceSheet
    attr_reader :engine, :accounts

    # Initialize a balance sheet.
    #
    # @param engine [Engine]
    def initialize(engine)
      @engine = engine
      @accounts = {}
    end

    # Get an account.
    #
    # @param id [String]
    #
    # @return [Account]
    def account(id = Util.uuid)
      @accounts[id] ||= Account.new(engine, id)
    end
    alias_method :[], :account

    # Count all balances amount in a given instrument.
    #
    # @param instrument [String, Symbol]
    #
    # @return [Numeric] total in +instrument+
    def count_all_in_instrument(instrument)
      accounts.reduce(Util.zero) do |memo, (_, account)|
        bal = account.balance(instrument)
        memo + bal.available + bal.reserved
      end
    end

    # Count all balances in all instruments.
    #
    # @return [Hash{String => Numeric}]
    def count_all
      engine.instrument_registry.names.map do |instrument_name|
        [instrument_name, count_all_in_instrument(instrument_name)]
      end.to_h
    end
  end
end
