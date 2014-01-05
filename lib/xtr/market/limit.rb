module Xtr
  class Market
    # Represents a group of orders at a specific price point in the
    # orderbook.
    class Limit
      attr_reader :price, :direction, :size, :orders, :filled_orders

      # Initialize a new +Limit+.
      #
      # @param price [BigDecimal] limit price level
      # @param direction [Symbol] limit direction (+:buy+ or +:sell+)
      def initialize(price, direction)
        @price = price
        @direction = direction
        @size = Util.zero
        @orders = []
        @filled_orders = []
      end

      # @return [Boolean]
      def buy?
        direction == :buy
      end

      # @return [Boolean]
      def sell?
        direction == :sell
      end

      # Add an order to the limit.
      #
      # @param order [Order]
      def add(order)
        @orders << order
        @size += order.remainder
      end

      # Remove an order.
      #
      # @param order [Order]
      def remove(order)
        @size -= order.remainder if orders.delete(order)
      end

      # Get array of orders that can fill +amount+.
      #
      # @return [Array<Array>] +[order, fill]+ pairs
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

      # Fill +amount+.
      #
      # @param amount [BigDecimal]
      # @param other_order [Order]
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
        "#{Util.number_to_string(price)} x #{Util.number_to_string(size)}"
      end

      def inspect
        "#<#{self.class.name} price=#{Util.number_to_string(price)} direction=#{direction} order_count=#{orders.count} size=#{Util.number_to_string(size)}>"
      end
    end
  end
end
