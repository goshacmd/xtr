require 'securerandom'
require 'bigdecimal'

module Xtr
  module Util
    # Generate an UUID.
    #
    # @return [String]
    def uuid
      SecureRandom.uuid
    end

    # Convert +number+ to a +BigDecimal+.
    #
    # @param number [BigDecimal, Float, Integer]
    # @return [BigDecimal]
    def big_decimal(number)
      if BigDecimal === number
        number
      elsif Float === number
        BigDecimal.new(number.to_s)
      else
        BigDecimal.new(number)
      end
    end

    # @return [BigDecimal]
    def zero
      self.big_decimal(0)
    end

    # Convert a number to a string.
    #
    # @param number [BigDecimal, Integer]
    # @return [String]
    def number_to_string(number)
      if BigDecimal === number
        number.to_s('F')
      else
        number.to_s
      end
    end

    extend self
  end
end
