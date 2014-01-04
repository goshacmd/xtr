module Xtr
  # Public: A query interface for engine.
  class QueryInterface
    include Queryable

    # Public: Initialize a query interface.
    #
    # engine - The Engine instance.
    def initialize(engine)
      @engine = engine
    end

    def context
      @engine
    end

    # Query: Get all balances for account.
    query :BALANCES do |account_id|
      account = account(account_id)

      instrument_registry.names.map do |instrument_name|
        account.balance(instrument_name).as_json
      end
    end

    # Query: Get account's balance in specific instrument.
    query :BALANCE do |account_id, instrument|
      account(account_id).balance(instrument).as_json
    end

    # Query: Get account's open orders.
    query :OPEN_ORDERS do |account_id|
      account(account_id).open_orders.map(&:as_json)
    end

    # Query: Get a list of markets.
    query :MARKETS do
      markets.values.map(&:as_json)
    end

    # Query: Get a ticker for the market.
    query :TICKER do |market_name|
      market(market_name).ticker
    end
  end
end
