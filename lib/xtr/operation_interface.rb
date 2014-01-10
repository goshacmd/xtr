module Xtr
  # An operation for engine.
  class OperationInterface
    attr_reader :journal

    # Initialize a new +OperationInterface+.
    #
    # @param engine [Engine]
    # @param journal [Journal]
    def initialize(engine, journal)
      @engine = engine
      @journal = journal
      @serial = 0
    end

    # Increment serial and return the new value.
    #
    # @return [Integer]
    def inc_serial
      @serial += 1
    end

    # Execute an operation with name +name+ and pass +args+ to it.
    #
    # @param name [String] operation name
    # @param args [Array] operation arguments
    # @return [void]
    def execute(name, *args)
      # TODO: make operation aliasing properly
      if [:BUY, :SELL].include?(name)
        args.unshift(name.to_s.downcase.to_sym)
        name = :create_limit
      end

      op = Operation.build(name, inc_serial, Time.now, *args)
      journal.record(op)
      op.perform(@engine)
    end

    # Execute an operation from journal.
    #
    # @param op [Operation]
    # @return [void]
    def execute_op(op)
      op.perform(@engine)
    end
  end
end
