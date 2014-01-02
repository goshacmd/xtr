require 'logger'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation'

require 'xtr/core_ext/numeric'

require 'xtr/version'
require 'xtr/util'
require 'xtr/errors'

module Xtr
  extend ActiveSupport::Autoload

  autoload :Account
  autoload :Balance
  autoload :BalanceCollection
  autoload :BalanceSheet
  autoload :Engine
  autoload :InstrumentRegistry
  autoload :Instruments
  autoload :Market
  autoload :OperationInterface
  autoload :Operationable
  autoload :Reservation
  autoload :Supermarket

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new '/dev/null'
    end
  end
end
