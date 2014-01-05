require 'rbtree'
require 'delegate'

module Xtr
  class Market
    module Trees
      # A basic tree.
      #
      # @abstract
      class Basic < Delegator
        def initialize
          @tree = RBTree.new
          super(@tree)
        end

        # Get the best price.
        #
        # @abstract
        #
        # @return [BigDecimal]
        def best_price
          raise NotImplementedError
        end

        # Get the limit at the best price.
        #
        # @abstract
        #
        # @return [Limit]
        def best_limit
          raise NotImplementedError
        end

        # Delete the best limit.
        #
        # @abstract
        def delete_best
          raise NotImplementedError
        end

        # @abstract
        #
        # @yield [Limit]
        def take_best_while
          raise NotImplementedError
        end

        # Check if an order with price +price+ can be filled from the tree.
        #
        # @abstract
        #
        # @return [Boolean]
        def can_fill_price?(price)
          raise NotImplementedError
        end

        # Delete blank limit records.
        def cleanup
          delete_best while best_limit && best_limit.size == 0
        end

        private

        def __getobj__
          @tree
        end

        def __setobj__(obj)
          @tree = obj
        end
      end

      # A bids tree.
      class Bids < Basic
        def best_price
          last && last[0]
        end

        def best_limit
          last && last[1]
        end

        def delete_best
          pop
        end

        def take_best_while(&block)
          reverse_each.take_while(&block)
        end

        def can_fill_price?(price)
          !!lower_bound(price)
        end
      end

      # An asks tree.
      class Asks < Basic
        def best_price
          first && first[0]
        end

        def best_limit
          first && first[1]
        end

        def delete_best
          shift
        end

        def take_best_while(&block)
          take_while(&block)
        end

        def can_fill_price?(price)
          !!upper_bound(price)
        end
      end
    end
  end
end
