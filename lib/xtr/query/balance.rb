module Xtr
  class Query
    class Balance < Query
      attr_reader :account_id, :instrument_name

      # @param account_id [String]
      # @param instrument_name [String]
      def initialize(account_id, instrument_name)
        @account_id = account_id
        @instrument_name = instrument_name
      end

      def execute(engine)
        engine.account(account_id).balance(instrument_name).as_json
      end
    end
  end
end
