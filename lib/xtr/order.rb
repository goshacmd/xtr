module Xtr
  # Public: An orderbook order.
  class Order
    attr_reader :account, :market, :direction, :price, :quantity, :uuid,
      :reserve_id, :remainder, :fills, :status, :created_at, :canceled_at

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
      @remainder = Util.big_decimal(quantity)
      @fills = []
      @filled = false
      @status = :initialized
      @uuid = uuid
      @created_at = Time.now
    end

    # Public: Check if order direction is :buy.
    def buy?
      direction == :buy
    end

    # Public: Check if order direction is :sell.
    def sell?
      direction == :sell
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

    # Public: Check if order is rejected.
    def rejected?
      status == :rejected
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

    # Public: Get the offered instrument symbol.
    def offered
      buy? ? market.right.name : market.left.name
    end

    # Public: Calculate received amount.
    #
    # price    - The optional BigDecimal price. Default: order price.
    # quantity - The Optional BigDecimal quantity. Default: order quantity.
    def received_amount(price = price, quantity = quantity)
      sell? ? price * quantity : quantity
    end

    # Public: Get the received instrument symbol.
    def received
      sell? ? market.right.name : market.left.name
    end

    # Public: Reserve the order amount.
    def reserve
      @reserve_id = account.reserve(offered, offered_amount)
      account.open_orders << self
    end

    # Public: Release the order amount.
    def release(amount = nil)
      @reserve_id = account.release(offered, reserve_id, amount) if reserve_id
    end

    # Public: Debit the reserved order amount.
    def debit(amount = nil)
      @reserve_id = account.debit_reserved(offered, reserve_id, amount) if reserve_id
    end

    # Public: Credit received amount in received instrument.
    def credit(amount = received_amount)
      account.credit(received, amount)
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
    def add_fill(amount, price)
      @fills << [price, amount]
      @remainder -= amount

      @status = remainder == 0 ? :filled : :partially_filled

      release_delete
    end

    # Public: Cancel the order.
    def cancel!
      @status = :canceled
      @canceled_at = Time.now
      release_delete
    end

    # Public: Change status from initialized to new.
    # Reserve the funds.
    def prepare_add
      return unless status == :initialized

      reserve
      @status = :new
      true
    rescue NotEnoughFundsError
      @status = :rejected
      false
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
