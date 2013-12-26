module Xtr
  # Public: A reservation from the balance.
  class Reservation
    attr_reader :balance, :amount, :uuid, :released, :debited

    # Public: Initialize a reservation.
    #
    # balance - The Balance object.
    # amount  - The BigDecimal reservation amount.
    # uuid    - The optional reservation identifier.
    def initialize(balance, amount, uuid = Util.uuid)
      @balance = balance
      @amount = Util.big_decimal(amount)
      @uuid = uuid
      @released = Util.zero
      @debited = Util.zero
    end

    # Public: Get a reservation remainder.
    def remainder
      amount - released - debited
    end

    # Public: Check if remainder amount is zero.
    def zero?
      remainder == 0
    end

    # Public: Release an amount from the reservation.
    #
    # amount - The optional BigDecimal amount. Default: remainder.
    def release(amount = remainder)
      amount = Util.big_decimal(amount)
      @released += amount if ensure_can_use(amount)
    end

    # Public: Release an amount from the reservation.
    #
    # amount - The optional BigDecimal amount. Default: remainder.
    def debit(amount = remainder)
      amount = Util.big_decimal(amount)
      @debited += amount if ensure_can_use(amount)
    end

    def inspect
      "#<#{self.class.name} id=#{uuid} balance=#{balance.uuid} amount=#{amount.to_f} remainder=#{remainder}>"
    end

    private

    # Private: Ensure a specific amount can be released/debited from the
    # reservation.
    #
    # amount - The BigDecimal amount.
    #
    # Returns true if the needed amount is available.
    # Raises NotEnoughFundsReservedError otherwise.
    def ensure_can_use(amount)
      return true if remainder >= amount
      raise NotEnoughFundsReservedError,
        "Not enough funds on #{uuid} reservation (remainder: #{remainder.to_f}, needed: #{amount.to_f})"
    end
  end
end
