require 'logger'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation'

require 'xtr/version'
require 'xtr/util'
require 'xtr/errors'

module Xtr
  extend ActiveSupport::Autoload

  autoload :Account
  autoload :Balance
  autoload :BalanceSheet
  autoload :Engine
  autoload :Execution
  autoload :Instruments
  autoload :Limit
  autoload :Market
  autoload :Operationable
  autoload :Order
  autoload :Orderbook
  autoload :Reservation
  autoload :Supermarket
  autoload :Trees

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new '/dev/null'
    end
  end
end
