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

    op :DEPOSIT do |account, currency, amount|
      balance_sheet[account].credit(currency, amount)
    end

    op :WITHDRAW do |account, currency, amount|
      balance_sheet[account].debit(currency, amount)
    end

    op :CREATE_LMT_ORDER do |account, left, right, direction, price, quantity|
      account = balance_sheet[account]
      market = supermarket[left, right]
      order = supermarket.create_order account, market, direction, price, quantity
      order.uuid
    end

    op :CANCEL_ORDER do |account, order|
      account = balance_sheet[account]
      order = account.open_orders.find { |o| o.uuid == order }
      supermarket.cancel_order order if order
    end
  end
end
