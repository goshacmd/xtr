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
        # @return [BigDecimal]
        def best_price
          raise NotImplementedError
        end

        # Get the limit at the best price.
        #
        # @return [Limit]
        def best_limit
          raise NotImplementedError
        end

        # Delete the best limit.
        #
        # @return [void]
        def delete_best
          raise NotImplementedError
        end

        # @yield [Limit]
        def take_best_while
          raise NotImplementedError
        end

        # Check if an order with price +price+ can be filled from the tree.
        def can_fill_price?(price)
          raise NotImplementedError
        end

        # Delete blank limit records.
        #
        # @return [void]
        def cleanup
          delete_best while best_limit && best_limit.size == 0
        end

        protected

        def __getobj__
          @tree
        end

        def __setobj__(obj)
          @tree = obj
        end
      end

      # A bids tree.
      class Bids < Basic
        # (see Basic#best_price)
        def best_price
          last && last[0]
        end

        # (see Basic#best_limit)
        def best_limit
          last && last[1]
        end

        # (see Basic#delete_best)
        def delete_best
          pop
        end

        # (see Basic#take_best_while)
        def take_best_while(&block)
          reverse_each.take_while(&block)
        end

        # (see Basic#can_fill_price?)
        def can_fill_price?(price)
          !!lower_bound(price)
        end
      end

      # An asks tree.
      class Asks < Basic
        # (see Basic#best_price)
        def best_price
          first && first[0]
        end

        # (see Basic#best_limit)
        def best_limit
          first && first[1]
        end

        # (see Basic#delete_best)
        def delete_best
          shift
        end

        # (see Basic#take_best_while)
        def take_best_while(&block)
          take_while(&block)
        end

        # (see Basic#can_fill_price?)
        def can_fill_price?(price)
          !!upper_bound(price)
        end
      end
    end
  end
end
