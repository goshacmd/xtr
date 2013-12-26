module Xtr
  # Public: An orderbook order.
  class Order
    attr_reader :account, :market, :direction, :price, :quantity, :uuid,
      :reserve_id, :remainder, :fills, :status, :created_at

    # Public: Initialize an order.
    #
    # account   - The Account initiating the order.
    # market    - The Market to create an order in.
    # direction - The Symbol direction of the order. Possible: :buy, :sell.
    # price     - The BigDecimal price.
    # quantity  - The BigDecimal quantity.
    def initialize(account, market, direction, price, quantity, uuid = Util.uuid)
      @account = account
      @market = market
      @direction = direction
      @price = Util.big_decimal(price)
      @quantity = Util.big_decimal(quantity)
      @remainder = quantity
      @fills = []
      @filled = false
      @status = :new
      @uuid = uuid
      @created_at = Time.now
    end

    # Public: Check if order direction is :buy.
    def buy?
      direction == :buy
    end

    # Public: Check if order direction is :sell.
    def sell?
      !buy?
    end

    # Public: Check if order is new.
    def new?
      status == :new
    end

    # Public: Check if order is filled.
    def filled?
      status == :filled
    end

    # Public: Check if order is paertially filled.
    def partially_filled?
      status == :partially_filled
    end

    # Public: Check if order is canceled.
    def canceled?
      status == :canceled
    end

    # Public: Check if the order isn't filled.
    def unfilled?
      new? || partially_filled?
    end

    # Public: Calculate offered amount.
    #
    # price    - The optional BigDecimal price. Default: order price.
    # quantity - The Optional BigDecimal quantity. Default: order quantity.
    def offered_amount(price = price, quantity = quantity)
      buy? ? price * quantity : quantity
    end

    # Public: Get the offered currency symbol.
    def offered_currency
      buy? ? market.right_currency : market.left_currency
    end

    # Public: Calculate received amount.
    #
    # price    - The optional BigDecimal price. Default: order price.
    # quantity - The Optional BigDecimal quantity. Default: order quantity.
    def received_amount(price = price, quantity = quantity)
      sell? ? price * quantity : quantity
    end

    # Public: Get the received currency symbol.
    def received_currency
      sell? ? market.right_currency : market.left_currency
    end

    # Public: Reserve the order amount.
    def reserve
      @reserve_id = account.reserve(offered_currency, offered_amount)
      account.open_orders << self
    end

    # Public: Release the order amount.
    def release(amount = nil)
      account.release(offered_currency, reserve_id, amount)
    end

    # Public: Debit the reserved order amount.
    def debit(amount = nil)
      account.debit_reserved(offered_currency, reserve_id, amount)
    end

    # Public: Credit received amount in received currency.
    def credit(amount = received_amount)
      account.credit(received_currency, amount)
    end

    # Public: Release order amount and remove from account's open orders if it
    # is filled or canceled.
    def release_delete
      if filled? || canceled?
        release
        account.open_orders.delete(self)
      end
    end

    # Public: Fill the order with `amount` at `price`.
    def fill(amount, price)
      @fills << [price, amount]
      @remainder -= amount

      @status = remainder == 0 ? :filled : :partially_filled

      debit_amount = offered_amount(price, amount)
      credit_amount = received_amount(price, amount)

      debit(debit_amount)
      credit(credit_amount)

      Xtr.logger.debug "filled order #{uuid} with #{amount.to_f} at #{price.to_f} (debited: #{debit_amount.to_f}, credited: #{credit_amount.to_f})"

      release_delete
    end

    # Public: Cancel the order.
    def cancel!
      @status = :canceled
      release_delete
    end

    # Public: Get the amount to be filled, limited by cap.
    def remainder_with_cap(cap)
      remainder >= cap ? cap : remainder
    end

    # Public: Get order type.
    def type
      :LMT
    end

    def inspect
      "#<#{self.class.name} market=#{market.pair} dir=#{direction} price=#{price} qty=#{quantity} left=#{remainder} id=#{uuid} account=#{account.uuid}>"
    end

    def to_s
      "(#{market.pair} #{price.to_f} x #{quantity.to_f} (left: #{remainder.to_f}), #{account.uuid})"
    end
  end
end
