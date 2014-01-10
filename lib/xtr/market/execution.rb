module Xtr
  class Market
    # An order execution.
    class Execution
      attr_reader :buy_order, :sell_order, :amount, :uuid, :price, :executed_at

      # Initialize a new +Execution+ for two orders.
      #
      # @param order1 [Order]
      # @param order2 [Order]
      # @param amount [Numeric] amount to execute
      # @param uuid [String] execution identifier
      def initialize(order1, order2, amount, uuid = Util.uuid)
        buy_order, sell_order = order1.buy? ? [order1, order2] : [order2, order1]

        @buy_order = buy_order
        @sell_order = sell_order
        @amount = amount
        @uuid = uuid
      end

      # Compute execution price.
      #
      # @return [Numeric]
      def computed_price
        # Use the price of the order that was submitted earlier than the other.
        [buy_order, sell_order].sort_by(&:created_at).first.price
      end

      # Transfer amounts between buyer/seller accounts.
      #
      # @param left_amount [Numeric]
      # @param right_amount [Numeric]
      # @return [void]
      def transfer(left_amount, right_amount)
        buy_order.debit(right_amount)
        sell_order.credit(right_amount)
        sell_order.debit(left_amount)
        buy_order.credit(left_amount)
      end

      # Execute.
      #
      # @return [void]
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
