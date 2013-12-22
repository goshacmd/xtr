module Xtr
  # Public: Represents a group of orders at a specific price point in the
  # orderbook.
  class Limit
    attr_reader :price, :size, :orders, :filled_orders

    # Public: Initialize a limit.
    #
    # price - The BigDecimal price.
    def initialize(price)
      @price = price
      @size = Util.zero
      @orders = []
      @filled_orders = []
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
      @size -= order.remainder if @orders.delete(order)
    end

    # Public: Fill `amount`.
    #
    # amount - The BigDecimal amount.
    def fill(amount)
      amount = Util.big_decimal(amount)
      filled = Util.zero

      Xtr.logger.debug "filling limit #{price.to_f} - #{amount.to_f}"

      unless filled == amount
        order = orders.shift
        fill = order.remainder_with_cap(amount)
        order.fill(fill, price)
        filled += fill

        if order.filled?
          filled_orders.push(order)
        else
          orders.unshift(order)
        end
      end

      @size -= amount
    end

    def inspect
      "#<#{self.class.name} price=#{price.to_f} order_count=#{orders.count} size=#{size.to_f}>"
    end
  end
end
