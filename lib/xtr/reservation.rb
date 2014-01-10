module Xtr
  # A reservation from the balance.
  class Reservation
    attr_reader :balance, :amount, :uuid, :released, :debited

    # @!method convert_quantity
    # @see CashBalance#convert_quantity
    delegate :convert_quantity, to: :balance

    # Initialize a new +Reservation+.
    #
    # @param balance [Balance] balance from which +amount+ is reserved
    # @param amount [Numeric] reservation amount
    # @param uuid [String] reservation identifier
    def initialize(balance, amount, uuid = Util.uuid)
      @balance = balance
      @amount = convert_quantity(amount)
      @released = convert_quantity(0)
      @debited = convert_quantity(0)
      @uuid = uuid
    end

    # Get a reservation remainder.
    #
    # @return [Numeric]
    def remainder
      amount - released - debited
    end

    # Check if remainder amount is zero.
    def zero?
      remainder == 0
    end

    # Release an amount from the reservation.
    #
    # @param amount [Numeric]
    # @return [void]
    def release(amount = remainder)
      amount = convert_quantity(amount)
      @released += amount if ensure_can_use(amount)
    end

    # Release an amount from the reservation.
    #
    # @param amount [Numeric]
    # @return [void]
    def debit(amount = remainder)
      amount = convert_quantity(amount)
      @debited += amount if ensure_can_use(amount)
    end

    def inspect
      "#<#{self.class.name} id=#{uuid} balance=#{balance.uuid} amount=#{Util.number_to_string(amount)} remainder=#{Util.number_to_string(remainder)}>"
    end

    private

    # Ensure a specific amount can be released/debited from the
    # reservation.
    #
    # @param amount [Numeric]
    #
    # @raise [NotEnoughFundsReservedError] if the needed amount is not
    # available
    #
    # @return [Boolean]
    def ensure_can_use(amount)
      return true if remainder >= amount
      raise NotEnoughFundsReservedError,
        "Not enough funds on #{uuid} reservation (remainder: #{remainder.to_f}, needed: #{amount.to_f})"
    end
  end
end
