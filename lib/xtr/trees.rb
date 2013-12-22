require 'algorithms'
require 'delegate'

module Xtr
  module Trees
    # Public: A basic tree.
    class Basic < Delegator
      def initialize
        @tree = Containers::RBTreeMap.new
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
        get(best_price)
      end

      # Public: Delete the best limit.
      def delete_best
        raise NotImplementedError
      end

      # Public: Check if an order with price `price` can be filled from the tree.
      def can_fill_price(price)
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
        max_key
      end

      def delete_best
        delete_max
      end

      def can_fill_price(price)
        price && best_price && best_price >= price
      end
    end

    # Public: An asks tree.
    class Asks < Basic
      def best_price
        min_key
      end

      def delete_best
        delete_min
      end

      def can_fill_price(price)
        price && best_price && best_price <= price
      end
    end
  end
end
