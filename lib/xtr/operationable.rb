require 'active_support/concern'

module Xtr
  # Public: A module to add operation capabilities to the class.
  #
  # Examples
  #
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

    # Public: Execute an operation with name `op_name` and pass
    # other arguments to the operation block.
    def execute(op_name, *args)
      block = self.class.op(op_name)
      instance_exec(*args, &block)
    end

    # Public: Execute a query with name `query_name` and pass other
    # arguments to the query block.
    def query(name, *args)
      block = self.class.query(name)
      instance_exec(*args, &block)
    end

    module ClassMethods
      # Public: Get/set operation block.
      def op(name, &block)
        @ops ||= {}
        @ops[name] = block if block_given?
        @ops[name]
      end

      # Public: Get/set query block.
      def query(name, &block)
        @queries ||= {}
        @queries[name] = block if block_given?
        @queries[name]
      end
    end
  end
end
