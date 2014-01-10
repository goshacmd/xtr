module Xtr
  # User operation.
  #
  # @abstract
  class Operation
    extend ActiveSupport::Autoload

    autoload :Deposit
    autoload :Withdraw
    autoload :CreateLimit
    autoload :Cancel

    attr_reader :serial, :time

    # Initialize a new +Operation+.
    #
    # @param serial [Integer] operation serial number
    # @param time [Time] time operation was executed
    def initialize(serial, time, *args)
      @serial = serial
      @time = time
    end

    # Execute an operation.
    #
    # @param engine [Engine]
    def execute(engine)
      raise NotImplementedError
    end

    def perform(*args)
      execute(*args)
    end

    class << self
      # Lookup operation with +name+.
      #
      # @param name [String]
      def lookup(name)
        const_get(name.to_s.downcase.camelize)
      rescue NameError
        raise NoSuchOperationError, "No operation named #{name} was found"
      end

      # Build operation.
      #
      # @param name [String] operation name
      # @param args [Array] operation arguments
      def build(name, *args)
        lookup(name).new(*args)
      end
    end
  end
end
