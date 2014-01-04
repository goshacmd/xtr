require 'securerandom'
require 'bigdecimal'

module Xtr
  module Util
    def self.uuid
      SecureRandom.uuid
    end

    def self.big_decimal(number)
      if BigDecimal === number
        number
      elsif Float === number
        BigDecimal.new(number.to_s)
      else
        BigDecimal.new(number)
      end
    end

    def self.zero
      self.big_decimal(0)
    end

    def self.number_to_string(number)
      if BigDecimal === number
        number.to_s('F')
      else
        number.to_s
      end
    end
  end
end
