module Xtr
  # Public: A balance sheet of all accounts.
  class BalanceSheet
    attr_reader :accounts

    # Public: Initialize a balance sheet.
    def initialize
      @accounts = {}
    end

    # Public: Get an account.
    def account(id = Util.uuid)
      @accounts[id] ||= Account.new
    end
    alias_method :[], :account

    # Public: Count all balances amount in a given currency.
    def count_all_in_currency(currency)
      accounts.reduce(Util.zero) do |memo, (_, account)|
        bal = account.balance(currency)
        memo + bal.available + bal.reserved
      end
    end
  end
end
