module Xtr
  class Operation
    # Withdrawal operation.
    class Withdraw < Operation
      attr_reader :account_id, :instrument_name, :amount

      # @param account_id [String]
      # @param instrument_name [String]
      # @param amount [String, Numeric]
      def initialize(serial, time, account_id, instrument_name, amount)
        super
        @account_id = account_id
        @instrument_name = instrument_name
        @amount = amount
      end

      def execute(engine)
        engine.account(account_id).debit(instrument_name, amount)
      end
    end
  end
end
