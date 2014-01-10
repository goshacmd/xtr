module Xtr
  # A query interface for engine.
  class QueryInterface
    # Intiialize a +QueryInterface+.
    #
    # @param engine [Engine]
    def initialize(engine)
      @engine = engine
    end

    # Execute a query.
    #
    # @param name [String] query name
    # @param args [Array] query arguments
    def query(name, *args)
      Query.build(name, *args).perform(@engine)
    end
  end
end
