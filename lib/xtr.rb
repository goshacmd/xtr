require 'logger'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation'
require 'active_support/concern'

require 'xtr/core_ext/numeric'

require 'xtr/version'
require 'xtr/util'
require 'xtr/errors'

module Xtr
  extend ActiveSupport::Autoload

  autoload :Account
  autoload :BalanceCollection
  autoload :BalanceSheet
  autoload :CashBalance
  autoload :Engine
  autoload :InstrumentRegistry
  autoload :Instrument
  autoload :Market
  autoload :OperationInterface
  autoload :Operationable
  autoload :QueryInterface
  autoload :Queryable
  autoload :Reservation
  autoload :Supermarket

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new '/dev/null'
    end
  end
end
