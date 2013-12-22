module Xtr
  # Public: A trading engine. Essentially, a container for a supermarket and
  # a balance sheet.
  class Engine
    attr_reader :supermarket, :balance_sheet

    def initialize
      @supermarket = Supermarket.new
      @balance_sheet = BalanceSheet.new
    end
  end
end
