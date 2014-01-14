module Xtr
  class Engine
    # Engine configuration.
    class Config
      # Set journal.
      #
      # @param args [Array] journal description.
      #   First item is journal type, the rest is just passed to journal initializer
      # @return [Array]
      def journal(*args)
        @journal ||= [:dummy]
        @journal = args unless args.empty?
        @journal
      end

      # Set instruments.
      #
      # @param desc [Hash{Symbol => Array<Symbol>}] instruments map
      # @see InstrumentRegistry.build_instruments
      # @return [Hash{Symbol => Array<Symbol>}]
      def instruments(desc = nil)
        @instruments ||= {}
        @instruments = desc if desc
        @instruments
      end

      # Set currency instruments.
      #
      # @param list [Array<Symbol>] list of currency instrument names
      # @return [void]
      def currency(*list)
        @instruments ||= {}
        @instruments[:currency] = list
      end

      # Set stock instruments.
      #
      # @param list [Array<Symbol>] list of stock instrument names
      # @return [void]
      def stock(*list)
        @instruments ||= {}
        @instruments[:stock] = list
      end

      # Set resource instruments.
      #
      # @param list [Array<Symbol>] list of resource instrument names
      # @return [void]
      def resource(*list)
        @instruments ||= {}
        @instruments[:resource] = list
      end

      # Set markets.
      #
      # @param desc [Hash{Symbol => Proc}]
      # @see Supermarket.build_markets
      # @return [Hash{Symbol => Proc}]
      def markets(desc = nil)
        @markets ||= {
          currency: -> list, _ { list.combination(2) },
          stock: -> list, inst { list.product(inst[:currency]) },
          resource: -> list, inst { list.product(inst[:currency]) }
        }
        @markets = desc if desc
        @markets
      end

      # Set currency market generator proc.
      #
      # @return [void]
      def currency_markets(&block)
        markets
        @markets[:currency] = block
      end

      # Set stock market generator proc.
      #
      # @return [void]
      def stock_markets(&block)
        markets
        @markets[:stock] = block
      end

      # Set resource market generator proc.
      #
      # @return [void]
      def resource_markets(&block)
        markets
        @markets[:resource] = block
      end
    end
  end
end
