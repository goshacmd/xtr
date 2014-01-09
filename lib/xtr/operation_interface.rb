module Xtr
  # An operation for engine.
  class OperationInterface
    include Operationable

    attr_reader :journal

    # Initialize a new +OperationInterface+.
    #
    # @param engine [Engine]
    def initialize(engine, journal)
      @engine = engine
      @journal = journal
    end

    def context
      @engine
    end

    # Operation: Deposit amount of instrument to account.
    op :DEPOSIT do |account_id, instrument, amount|
      account(account_id).credit(instrument, amount)
    end

    # Operation: Withdraw amount of instrument from account.
    op :WITHDRAW do |account_id, instrument, amount|
      account(account_id).debit(instrument, amount)
    end

    # Operation: Create a LIMIT order.
    op :CREATE_LMT do |account_id, direction, market_name, price, quantity|
      account = account(account_id)
      market = market(market_name)
      order = supermarket.create_order account, market, direction, price, quantity
      order.uuid
    end

    # Operation: Create a buy order.
    op :BUY, log: false do |account_id, market_name, price, quantity|
      execute(:CREATE_LMT, account_id, :buy, market_name, price, quantity)
    end

    # Operation: Create a sell order.
    op :SELL, log: false do |account_id, market_name, price, quantity|
      execute(:CREATE_LMT, account_id, :sell, market_name, price, quantity)
    end

    # Operation: Cancel an order.
    op :CANCEL do |account_id, order_id|
      account = account(account_id)
      order = account.open_orders.find { |o| o.uuid == order_id }
      supermarket.cancel_order order if order
    end
  end
end
