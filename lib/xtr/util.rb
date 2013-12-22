require 'securerandom'
require 'bigdecimal'

module Xtr
  module Util
    def self.uuid
      SecureRandom.uuid
    end

    def self.big_decimal(number)
      if number.is_a?(BigDecimal)
        number
      elsif number.is_a?(Float)
        BigDecimal.new(number.to_s)
      else
        BigDecimal.new(number)
      end
    end

    def self.zero
      self.big_decimal(0)
    end
  end
end
