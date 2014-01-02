module Xtr
  # Public: A balance sheet of all accounts.
  class BalanceSheet
    attr_reader :engine, :accounts

    # Public: Initialize a balance sheet.
    def initialize(engine)
      @engine = engine
      @accounts = {}
    end

    # Public: Get an account.
    def account(id = Util.uuid)
      @accounts[id] ||= Account.new(engine, id)
    end
    alias_method :[], :account

    # Public: Count all balances amount in a given instrument.
    def count_all_in_instrument(instrument)
      accounts.reduce(Util.zero) do |memo, (_, account)|
        bal = account.balance(instrument)
        memo + bal.available + bal.reserved
      end
    end

    # Public: Count all balances in all instruments.
    def count_all
      engine.instrument_registry.names.map do |instrument_name|
        [instrument_name, count_all_in_instrument(instrument_name)]
      end.to_h
    end
  end
end
