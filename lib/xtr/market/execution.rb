module Xtr
  class Market
    # Public: An order execution.
    class Execution
      attr_reader :buy_order, :sell_order, :amount, :uuid, :price, :executed_at

      # Public: Initialize an execution for two orders.
      def initialize(order1, order2, amount, uuid = Util.uuid)
        buy_order, sell_order = order1.buy? ? [order1, order2] : [order2, order1]

        @buy_order = buy_order
        @sell_order = sell_order
        @amount = amount
        @uuid = uuid
      end

      # Public: Compute execution price.
      def computed_price
        # Use the price of the order that was submitted earlier than the other.
        [buy_order, sell_order].sort_by(&:created_at).first.price
      end

      # Public: Transfer amounts between buyer/seller accounts.
      def transfer(left_amount, right_amount)
        buy_order.debit(right_amount)
        sell_order.credit(right_amount)
        sell_order.debit(left_amount)
        buy_order.credit(left_amount)
      end

      # Public: Exectute.
      def execute
        price = computed_price

        left_amount = amount
        right_amount = price * amount

        transfer(left_amount, right_amount)

        [buy_order, sell_order].each { |o| o.add_fill(amount, price) }

        Xtr.logger.debug "matched orders: #{buy_order.uuid} and #{sell_order.uuid}, filling #{amount.to_f} at #{price.to_f}"

        @price = price
        @executed_at = Time.now
      end
    end
  end
end
