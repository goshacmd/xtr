module Xtr
  # User query.
  #
  # @abstract
  class Query
    extend ActiveSupport::Autoload

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

    class << self
      # Lookup query with +name+.
      #
      # @param name [String]
      # @return [Class]
      def lookup(name)
        const_get(name.to_s.downcase.camelize)
      rescue NameError
        raise NoSuchQueryError, "No query named #{name} was found"
      end

      # Build query.
      #
      # @param name [String] query name
      # @param args [Array] query arguments
      # @return [Query]
      def build(name, *args)
        lookup(name).new(*args)
      end
    end
  end
end
