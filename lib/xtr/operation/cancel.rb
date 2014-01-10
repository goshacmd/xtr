module Xtr
  class Operation
    # Order cancelation operation.
    class Cancel < Operation
      attr_reader :account_id, :order_id

      def initialize(serial, time, account_id, order_id)
        super
        @account_id = account_id
        @order_id = order_id
      end

      def execute(engine)
        account = engine.account(account_id)
        order = account.open_orders.find { |o| o.uuid == order_id }
        engine.supermarket.cancel_order order
      end
    end
  end
end
