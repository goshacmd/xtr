module Xtr
  class Query
    class OpenOrders < Query
      attr_reader :account_id

      # @param account_id [String]
      def initialize(account_id)
        @account_id = account_id
      end

      def execute(engine)
        engine.account(account_id).open_orders.map(&:as_json)
      end
    end
  end
end
