module Xtr
  # Public: A trading engine. Essentially, a container for a supermarket and
  # a balance sheet.
  class Engine
    include Operationable

    attr_reader :supermarket, :balance_sheet

    delegate :account, to: :balance_sheet

    def initialize
      @supermarket = Supermarket.new
      @balance_sheet = BalanceSheet.new
    end

    op :CREATE_ACCOUNT do
      account.uuid
    end

    op :DEPOSIT do |account_id, currency, amount|
      balance_sheet[account_id].credit(currency, amount)
    end

    op :WITHDRAW do |account_id, currency, amount|
      balance_sheet[account_id].debit(currency, amount)
    end

    op :CREATE_LMT_ORDER do |account_id, left, right, direction, price, quantity|
      account = balance_sheet[account_id]
      market = supermarket[left, right]
      order = supermarket.create_order account, market, direction, price, quantity
      order.uuid
    end

    op :CANCEL_ORDER do |account_id, order_id|
      account = balance_sheet[account_id]
      order = account.open_orders.find { |o| o.uuid == order_id }
      supermarket.cancel_order order if order
    end

    query :BALANCES do |account_id|
      account = balance_sheet[account_id]

      CURRENCIES.map do |currency|
        balance = account.balance(currency)
        {
          currency: balance.currency,
          available: balance.available.to_s('F'),
          reserved: balance.reserved.to_s('F')
        }
      end
    end

    query :OPEN_ORDERS do |account_id|
      account = balance_sheet[account_id]

      account.open_orders.map do |order|
        {
          id: order.uuid,
          market: order.market.pair,
          direction: order.direction,
          price: order.price.to_s('F'),
          quantity: order.quantity.to_s('F'),
          remainder: order.remainder.to_s('F'),
          status: order.status,
          created_at: order.created_at.to_s
        }
      end
    end
  end
end
