module Xtr
  # Public: An operation and query interface for engine.
  class OperationInterface
    include Operationable

    # Public: Initialize an operation interface.
    #
    # engine - The Engine instance.
    def initialize(engine)
      @engine = engine
    end

    def context
      @engine
    end

    op :CREATE_ACCOUNT do
      account.uuid
    end

    op :DEPOSIT do |account_id, instrument, amount|
      account(account_id).credit(instrument, amount)
    end

    op :WITHDRAW do |account_id, instrument, amount|
      account(account_id).debit(instrument, amount)
    end

    op :CREATE_LMT do |account_id, direction, market_name, price, quantity|
      account = account(account_id)
      market = market(market_name)
      order = supermarket.create_order account, market, direction, price, quantity
      order.uuid
    end

    op :BUY do |account_id, market_name, price, quantity|
      execute(:CREATE_LMT, account_id, :buy, market_name, price, quantity)
    end

    op :SELL do |account_id, market_name, price, quantity|
      execute(:CREATE_LMT, account_id, :sell, market_name, price, quantity)
    end

    op :CANCEL do |account_id, order_id|
      account = account(account_id)
      order = account.open_orders.find { |o| o.uuid == order_id }
      supermarket.cancel_order order if order
    end

    query :BALANCES do |account_id|
      account = account(account_id)

      instrument_registry.instruments.map do |instrument|
        query(:BALANCE, account_id, instrument.name)
      end
    end

    query :BALANCE do |account_id, instrument|
      account = account(account_id)
      balance = account.balance(instrument)

      {
        instrument: instrument,
        available: balance.available.to_s,
        reserved: balance.reserved.to_s
      }
    end

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

    query :MARKETS do
      markets.values.map do |market|
        {
          name: market.pair,
          type: market.type
        }
      end
    end

    query :TICKER do |market_name|
      market = market(market_name)
      last_price = market.last_price
      bid = market.best_bid
      ask = market.best_ask

      {
        bid: bid.to_s,
        ask: ask.to_s,
        last_price: last_price.to_s
      }
    end
  end
end
