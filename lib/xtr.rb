require 'logger'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation'

require 'xtr/version'
require 'xtr/util'
require 'xtr/errors'

module Xtr
  extend ActiveSupport::Autoload

  autoload :Account
  autoload :BalanceSheet
  autoload :CurrencyBalance
  autoload :Engine
  autoload :Execution
  autoload :Limit
  autoload :Market
  autoload :Operationable
  autoload :Order
  autoload :Orderbook
  autoload :Reservation
  autoload :Supermarket
  autoload :Trees

  CURRENCIES = [:BTC, :USD]

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new '/dev/null'
    end
  end
end
