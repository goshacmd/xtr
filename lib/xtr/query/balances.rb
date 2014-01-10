module Xtr
  class Query
    class Balances < Query
      attr_reader :account_id

      # @param account_id [String]
      def initialize(account_id)
        @account_id = account_id
      end

      def execute(engine)
        account = engine.account(account_id)

        engine.instrument_registry.names.map do |instrument_name|
          account.balance(instrument_name).as_json
        end
      end
    end
  end
end
