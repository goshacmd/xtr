require 'forwardable'

module Xtr
  # Public: A trading engine. Essentially, a container for a supermarket and
  # a balance sheet.
  class Engine
    extend Forwardable

    attr_reader :supermarket, :balance_sheet

    def_delegators :balance_sheet, :account

    def initialize
      @supermarket = Supermarket.new
      @balance_sheet = BalanceSheet.new
    end

    def execute(op_name, *args)
      block = self.class.op(op_name)
      instance_exec(*args, &block)
    end

    class << self
      def op(name, &block)
        @ops ||= {}

        @ops[name] = block if block_given?

        @ops[name]
      end
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
