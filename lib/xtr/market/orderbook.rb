module Xtr
  class Market
    # An order book.
    class Orderbook
      attr_reader :bids, :asks, :last_price

      # Initializes a new +Orderbook+.
      def initialize
        @bids = Trees::Bids.new
        @asks = Trees::Asks.new
        @last_price = nil
      end

      # Get best ask.
      #
      # @return [BigDecimal]
      def best_ask
        @asks.best_price
      end

      # Get best bid.
      #
      # @return [BigDecimal]
      def best_bid
        @bids.best_price
      end

      # Add a new order.
      #
      # @param order [Order]
      # @return [void]
      def add_order(order)
        price = order.price
        tree = tree_for_direction(order.direction)

        return unless order.prepare_add

        fill_order(order)

        limit = tree[price] ||= Limit.new(price, order.direction)
        limit.add(order) if order.unfilled?

        tree.delete(price) if limit.size.zero?
        tree.cleanup
      end

      # Cancel an order.
      #
      # @param order [Order]
      # @return [void]
      def cancel_order(order)
        return unless order.unfilled?

        price = order.price
        tree = tree_for_direction(order.direction)
        limit = tree[price]

        limit.remove(order) if limit
        order.cancel!

        tree.delete(price) if limit && limit.size.zero?
      end

      # Get the tree for order direction.
      #
      # @return [Trees::Basic]
      def tree_for_direction(direction)
        direction == :buy ? @bids : @asks
      end

      # Get the tree opposite of order direction.
      #
      # @return [Trees::Basic]
      def tree_opposite_direction(direction)
        direction == :buy ? @asks : @bids
      end

      # Get list of limits that can fill +amount+.
      #
      # @return [Array<Order>]
      def limits_to_fill(tree, amount)
        remaining = amount
        fills = []

        final_limits = tree.take_best_while do |price, limit|
          if remaining > 0
            fill = remaining.cap(limit.size)
            fills << fill
            remaining -= fill
          end
        end

        final_limits.map(&:last).zip(fills)
      end

      # Get the best offer from the opposite tree.
      #
      # @param order [Order]
      # @return [void]
      def fill_order(order)
        opposite = tree_opposite_direction(order.direction)

        if opposite.can_fill_price?(order.price)
          limits_to_fill(opposite, order.remainder).each do |limit, fill|
            limit.fill(fill, order)
            opposite.delete(limit.price) if limit.size.zero?
            @last_price = limit.price
          end
        end
      end
    end
  end
end
