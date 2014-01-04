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
        query(:BALANCE, account_id, instrument_name)
      end
    end

    # Query: Get account's balance in specific instrument.
    query :BALANCE do |account_id, instrument|
      account = account(account_id)
      balance = account.balance(instrument)

      {
        instrument: instrument,
        available: balance.available.to_s,
        reserved: balance.reserved.to_s
      }
    end

    # Query: Get account's open orders.
    query :OPEN_ORDERS do |account_id|
      account = account(account_id)

      account.open_orders.map do |order|
        {
          id: order.uuid,
          market: order.market.pair,
          direction: order.direction,
          price: order.price.to_s,
          quantity: order.quantity.to_s,
          remainder: order.remainder.to_s,
          status: order.status,
          created_at: order.created_at.to_s
        }
      end
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
