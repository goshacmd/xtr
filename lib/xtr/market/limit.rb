module Xtr
  class Market
    # Public: Represents a group of orders at a specific price point in the
    # orderbook.
    class Limit
      attr_reader :price, :direction, :size, :orders, :filled_orders

      # Public: Initialize a limit.
      #
      # price - The BigDecimal price.
      def initialize(price, direction)
        @price = price
        @direction = direction
        @size = Util.zero
        @orders = []
        @filled_orders = []
      end

      def buy?
        direction == :buy
      end

      def sell?
        direction == :sell
      end

      # Public: Add an order to the limit.
      #
      # order - The Order object.
      def add(order)
        @orders << order
        @size += order.remainder
      end

      # Public: Remove an order.
      #
      # order - The Order object.
      def remove(order)
        @size -= order.remainder if orders.delete(order)
      end

      # Public: Get array of orders that can fill `amount`.
      #
      # Returns an array of [order, fill] pairs.
      def orders_to_fill(amount)
        remaining = amount
        fills = []

        final_orders = orders.take_while do |order|
          if remaining > 0
            fill = order.remainder.cap(remaining)
            fills << fill
            remaining -= fill
          end
        end

        final_orders.zip(fills)
      end

      # Public: Fill `amount`.
      #
      # amount      - The BigDecimal amount.
      # other_order - The Order object.
      def fill(amount, other_order)
        amount = Util.big_decimal(amount)

        Xtr.logger.debug "filling limit #{price.to_f} - #{amount.to_f}"

        orders_to_fill(amount).each do |order, fill|
          execution = Execution.new(order, other_order, fill)
          execution.execute

          orders.shift if order.filled?
        end

        @size -= amount
      end

      def to_s
        "#{price.to_f} x #{size.to_f}"
      end

      def inspect
        "#<#{self.class.name} price=#{price.to_f} direction=#{direction} order_count=#{orders.count} size=#{size.to_f}>"
      end
    end
  end
end
