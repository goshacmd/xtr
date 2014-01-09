module Xtr
  # A module to add operation capabilities to the class.
  #
  # @example
  #   class Engine
  #     include Operationable
  #
  #     op :DEPOSIT do |account, currency, amount|
  #       balances[account].deposit(currency, amount)
  #     end
  #   end
  #
  #   engine = Engine.new
  #   engine.execute :DEPOSIT, '123', :USD, 10_000.00
  module Operationable
    extend ActiveSupport::Concern

    # Return previous serial number and increment it.
    def inc_serial
      @serial ||= 0
      serial, @serial = @serial, @serial + 1
      serial
    end

    # Execute an operation with name +op_name+ and pass
    # other arguments to the operation block.
    #
    # @param op_name [Symbol] operation name
    def execute(op_name, *args)
      block, log = self.class.op(op_name)

      if block
        journal.record(Operation.new(inc_serial, op_name, args)) if log
        context.instance_exec(*args, &block)
      else
        raise NoSuchOperationError, "No operation named #{op_name} was registered"
      end
    end

    module ClassMethods
      # Get/set operation block.
      #
      # @return [Proc]
      def op(name, log: true, &block)
        @ops ||= {}
        @ops[name] = [block, log] if block_given?
        @ops[name]
      end
    end
  end
end
