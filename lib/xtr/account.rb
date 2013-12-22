module Xtr
  class UnsupportedCurrencyException < RuntimeError; end

  # Public: An account.
  #
  # Examples
  #
  #   acc = Account.new
  #   acc.credit(:USD, 100.00)
  #   acc.balance(:USD) # => #<Balance account=123 currency=USD available=100.00 reserved=0.00>
  class Account
    attr_reader :uuid, :open_orders

    # Public: Initialize an account.
    #
    # uuid - The UUID string. Default: auto-generate.
    def initialize(uuid = Util.uuid)
      @uuid = uuid

      @open_orders = []

      @balances = Hash.new do |hash, key|
        if CURRENCIES.include?(key)
          hash[key] = CurrencyBalance.new(self, key)
        else
          raise UnsupportedCurrencyException, "#{key} is not a supported currency"
        end
      end
    end

    # Public: Get an account's balance in specific currency.
    #
    # currency - The Symbol currency code.
    def balance(currency)
      @balances[currency]
    end
    alias [] balance

    # Public: Credit funds to the `currency` balance.
    #
    # currency - The Symbol currency name.
    # amount   - The BigDecimal amount to credit.
    def credit(currency, amount)
      balance(currency).credit(amount)
    end

    # Public: Debit funds from the `currency` balance.
    #
    # currency - The Symbol currency name.
    # amount   - The BigDecimal amount to debit.
    def debit(currency, amount)
      balance(currency).debit(amount)
    end

    # Public: Reserve funds from the `currency` balance.
    #
    # currency - The Symbol currency name.
    # amount   - The BigDecimal amount to reserve.
    #
    # Returns a String reservation identifier.
    def reserve(currency, amount)
      balance(currency).reserve(amount)
    end

    # Public: Release funds from the `currency` reserve.
    #
    # currency   - The Symbol currency name
    # reserve_id - The String reservation identifier.
    # amount     - The optional BigDecimal amount to release. If not
    #              passed, all remaining funds will be released.
    def release(currency, reserve_id, amount)
      balance(currency).release(reserve_id, amount)
    end

    # Public: Debit funds from the `currency` reserved balance.
    #
    # currency   - The Symbol currency name.
    # reserve_id - The String reservation identifier.
    # amount     - The optional BigDecimal amount to release. If not
    #              passed, all remaining funds will be released.
    def debit_reserved(currency, reserve_id, amount = nil)
      balance(currency).debit_reserved(reserve_id, amount)
    end

    def inspect
      "#<#{self.class.name} id=#{uuid}>"
    end
  end
end
