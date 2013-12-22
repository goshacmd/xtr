require 'xtr/version'
require 'xtr/util'
require 'logger'

module Xtr
  autoload :Account, 'xtr/account'
  autoload :BalanceSheet, 'xtr/balance_sheet'
  autoload :CurrencyBalance, 'xtr/currency_balance'
  autoload :Engine, 'xtr/engine'
  autoload :Limit, 'xtr/limit'
  autoload :Market, 'xtr/market'
  autoload :Order, 'xtr/order'
  autoload :Orderbook, 'xtr/orderbook'
  autoload :Reservation, 'xtr/reservation'
  autoload :Supermarket, 'xtr/supermarket'
  autoload :Trees, 'xtr/trees'

  CURRENCIES = [:BTC, :USD]

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new '/dev/null'
    end
  end
end
