require 'rbtree'
require 'delegate'

module Xtr
  module Trees
    # Public: A basic tree.
    class Basic < Delegator
      def initialize
        @tree = RBTree.new
        super(@tree)
      end

      def __getobj__
        @tree
      end

      def __setobj__(obj)
        @tree = obj
      end

      # Public: Get the best price.
      def best_price
        raise NotImplementedError
      end

      # Public: Get the limit at the best price.
      def best_limit
        raise NotImplementedError
      end

      # Public: Delete the best limit.
      def delete_best
        raise NotImplementedError
      end

      def take_best_while
        raise NotImplementedError
      end

      # Public: Check if an order with price `price` can be filled from the tree.
      def can_fill_price?(price)
        raise NotImplementedError
      end

      # Public: Delete blank limit records.
      def cleanup
        delete_best while best_limit && best_limit.size == 0
      end
    end

    # Public: A bids tree.
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

    # Public: An asks tree.
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
