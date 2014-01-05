module Xtr
  # Public: A collection of account balances in different instruments.
  class BalanceCollection
    attr_reader :account, :engine

    # Public: Initialize a balance collection.
    #
    # account - The Account object.
    def initialize(account)
      @account = account
      @engine = account.engine

      @hash = Hash.new do |hash, key|
        if engine.supported_instrument?(key)
          instrument = engine.instrument_registry[key]
          hash[key] = CashBalance.new(account, instrument)
        else
          raise UnsupportedInstrumentError, "#{key} is not a supported instrument"
        end
      end
    end

    # Public: Get a balance for instrument.
    #
    # instrument - The String instrument name or Instrument object.
    def [](instrument)
      instrument = instrument.name if Instruments::Instrument === instrument
      @hash[instrument.to_s]
    end

    # Public: Get an array of balances, sorted by instrument name.
    def to_a
      @hash.values.sort_by { |b| b.instrument.name }
    end
  end
end
