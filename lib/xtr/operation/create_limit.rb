module Xtr
  class Operation
    # Create LIMIT order operation.
    class CreateLimit < Operation
      attr_reader :direction, :account_id, :market_name, :price, :quantity, :uuid

      # @param direction [String, Symbol]
      # @param account_id [String]
      # @param market_name [String]
      # @param price [String, Numeric]
      # @param quantity [String, Numeric]
      # @param uuid [String]
      def initialize(serial, time, direction, account_id, market_name, price, quantity, uuid = Util.uuid)
        super
        @direction = direction
        @account_id = account_id
        @market_name = market_name
        @price = price
        @quantity = quantity
        @uuid = uuid
      end

      def execute(engine)
        account = engine.account(account_id)
        market = engine.market(market_name)
        engine.supermarket.create_order account, market, direction, price, quantity, uuid
      end
    end
  end
end
