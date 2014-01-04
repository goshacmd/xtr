module Xtr
  # Public: A reservation from the balance.
  class Reservation
    attr_reader :balance, :amount, :uuid, :released, :debited

    delegate :convert_quantity, to: :balance

    # Public: Initialize a reservation.
    #
    # balance - The Balance object.
    # amount  - The reservation amount.
    # uuid    - The optional reservation identifier.
    def initialize(balance, amount, uuid = Util.uuid)
      @balance = balance
      @amount = convert_quantity(amount)
      @released = convert_quantity(0)
      @debited = convert_quantity(0)
      @uuid = uuid
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
    # amount - The optional amount. Default: remainder.
    def release(amount = remainder)
      amount = convert_quantity(amount)
      @released += amount if ensure_can_use(amount)
    end

    # Public: Release an amount from the reservation.
    #
    # amount - The optional amount. Default: remainder.
    def debit(amount = remainder)
      amount = convert_quantity(amount)
      @debited += amount if ensure_can_use(amount)
    end

    def inspect
      "#<#{self.class.name} id=#{uuid} balance=#{balance.uuid} amount=#{Util.number_to_string(amount)} remainder=#{Util.number_to_string(remainder)}>"
    end

    private

    # Private: Ensure a specific amount can be released/debited from the
    # reservation.
    #
    # amount - The amount.
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
