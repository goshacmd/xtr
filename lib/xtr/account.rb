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
      @uuid = uuid

      @open_orders = []

      @balances = Hash.new do |hash, key|
        if engine.supported_instrument?(key)
          instrument = engine.instrument_registry[key]
          hash[key] = Balance.new(self, instrument)
        else
          raise UnsupportedInstrumentError, "#{key} is not a supported instrument"
        end
      end
    end

    # Public: Get an account's balance in specific instrument.
    #
    # instrument - The Symbol instrument code.
    def balance(instrument)
      @balances[instrument]
    end
    alias [] balance

    # Public: Credit funds to the `instrument` balance.
    #
    # instrument - The Symbol instrument name.
    # amount     - The amount to credit.
    def credit(instrument, amount)
      balance(instrument).credit(amount)
    end

    # Public: Debit funds from the `instrument` balance.
    #
    # instrument - The Symbol instrument name.
    # amount     - The amount to debit.
    def debit(instrument, amount)
      balance(instrument).debit(amount)
    end

    # Public: Reserve funds from the `instrument` balance.
    #
    # instrument - The Symbol instrument name.
    # amount     - The amount to reserve.
    #
    # Returns a String reservation identifier.
    def reserve(instrument, amount)
      balance(instrument).reserve(amount)
    end

    # Public: Release funds from the `instrument` reserve.
    #
    # instrument - The Symbol instrument name
    # reserve_id - The String reservation identifier.
    # amount     - The optional amount to release. If not
    #              passed, all remaining funds will be released.
    def release(instrument, reserve_id, amount)
      balance(instrument).release(reserve_id, amount)
    end

    # Public: Debit funds from the `instrument` reserved balance.
    #
    # instrument - The Symbol instrument name.
    # reserve_id - The String reservation identifier.
    # amount     - The optional amount to release. If not
    #              passed, all remaining funds will be released.
    def debit_reserved(instrument, reserve_id, amount = nil)
      balance(instrument).debit_reserved(reserve_id, amount)
    end

    def to_s
      balances = @balances.values.sort_by { |b| b.instrument.name }
      "#{uuid} - #{balances.join(', ')}"
    end

    def inspect
      "#<#{self.class.name} id=#{uuid}>"
    end
  end
end
