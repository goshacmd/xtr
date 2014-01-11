module Xtr
  # User query.
  #
  # @abstract
  class Query
    extend ActiveSupport::Autoload
    extend Building

    autoload :Balances
    autoload :Balance
    autoload :OpenOrders
    autoload :Markets
    autoload :Ticker

    def initialize(*args)
    end

    # Execute a query.
    #
    # @param engine [Engine]
    def execute(engine)
      raise NotImplementedError
    end

    def perform(*args)
      execute(*args)
    end
  end
end
