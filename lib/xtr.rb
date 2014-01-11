require 'logger'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/concern'
require 'active_support/dependencies/autoload'

require 'xtr/core_ext/numeric'

require 'xtr/version'
require 'xtr/util'
require 'xtr/errors'

module Xtr
  extend ActiveSupport::Autoload

  autoload :Account
  autoload :BalanceCollection
  autoload :BalanceSheet
  autoload :Building
  autoload :CashBalance
  autoload :Engine
  autoload :InstrumentRegistry
  autoload :Journal
  autoload :Instrument
  autoload :Market
  autoload :Operation
  autoload :OperationInterface
  autoload :Query
  autoload :QueryInterface
  autoload :Reservation
  autoload :Supermarket

  class << self
    attr_writer :logger

    # Get a global logger.
    #
    # @return [Logger]
    def logger
      @logger ||= Logger.new '/dev/null'
    end
  end
end
