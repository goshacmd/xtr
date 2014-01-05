module Xtr
  # A module to add query capabilities to the class.
  #
  # @example
  #   class Engine
  #     include Queryable
  #
  #     query :TICKER do |market_id|
  #       market(market_id).ticker
  #     end
  #   end
  #
  #   engine = Engine.new
  #   engine.query :TICKER, "BTC/USD"
  module Queryable
    extend ActiveSupport::Concern

    # Execute a query with name +query_name+ and pass other
    # arguments to the query block.
    #
    # @param name [String] query name
    def query(name, *args)
      block = self.class.query(name)

      if block
        context.instance_exec(*args, &block)
      else
        raise NoSuchOperationError, "No operation named #{query} was registered"
      end
    end

    module ClassMethods
      # Get/set query block.
      #
      # @return [Proc]
      def query(name, &block)
        @queries ||= {}
        @queries[name] = block if block_given?
        @queries[name]
      end
    end
  end
end
