module Xtr
  class Query
    class Markets < Query
      def execute(engine)
        engine.markets.values.map(&:as_json)
      end
    end
  end
end
