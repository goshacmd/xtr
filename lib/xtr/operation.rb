module Xtr
  # User operation.
  #
  # @abstract
  class Operation
    extend ActiveSupport::Autoload
    extend Building

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
  end
end
