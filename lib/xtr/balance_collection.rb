module Xtr
  # A collection of account balances in different instruments.
  class BalanceCollection
    attr_reader :account, :engine

    # Initialize a new +BalanceCollection+.
    #
    # @param account [Account]
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

    # Get a balance for instrument.
    #
    # @param instrument [String, Symbol, Instrument] instrument code
    #
    # @return [CashBalance]
    def [](instrument)
      instrument = instrument.name if Instruments::Instrument === instrument
      @hash[instrument.to_s]
    end

    # Get an array of balances, sorted by instrument name.
    def to_a
      @hash.values.sort_by { |b| b.instrument.name }
    end
  end
end
