module Xtr
  # Public: An order book.
  class Orderbook
    attr_reader :bids, :asks, :last_price

    # Public: Initialize an order book.
    def initialize
      @bids = Trees::Bids.new
      @asks = Trees::Asks.new
      @last_price = nil
    end

    # Public: Get best ask.
    def best_ask
      @asks.best_price
    end

    # Public: Get best bid.
    def best_bid
      @bids.best_price
    end

    # Public: Add a new order.
    #
    # order - The Order object.
    def add_order(order)
      price = order.price
      tree = tree_for_direction(order.direction)

      return unless order.prepare_add

      fill_order(order)

      limit = tree.get(price) || Limit.new(price, order.direction)
      limit.add(order) if order.unfilled?

      tree.push(price, limit)
      tree.delete(price) if limit.size.zero?
      tree.cleanup
    end

    # Public: Cancel an order.
    #
    # order - The order object.
    def cancel_order(order)
      return unless order.unfilled?

      price = order.price
      tree = tree_for_direction(order.direction)
      limit = tree.get(price)

      limit.remove(order) if limit
      order.cancel!

      tree.delete(price) if limit && limit.size.zero?
    end

    private

    # Private: Get the tree for order direction.
    def tree_for_direction(direction)
      direction == :buy ? @bids : @asks
    end

    # Private: Get the tree opposite of order direction.
    def tree_opposite_direction(direction)
      direction == :buy ? @asks : @bids
    end

    # Private: Get the best offer from the opposite tree.
    #
    # order - The Order object.
    def fill_order(order)
      opposite = tree_opposite_direction(order.direction)
      filled = Util.zero

      if opposite.can_fill_price(order.price)
        while filled < order.quantity && order.unfilled? && opposite.can_fill_price(order.price)
          price, limit = opposite.best_price, opposite.best_limit
          amount = order.remainder_with_cap(limit.size)
          limit.fill(amount, order)
          opposite.delete(price) if limit.size.zero?
          filled += amount
          @last_price = price
        end
      end

      filled
    end
  end
end
