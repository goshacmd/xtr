module Xtr
  # A cash balance of an account.
  #
  # @example
  #   cb = CashBalance.new acc, USD
  #   cb.credit(10_000.00)
  #   cb.available # => 10_000.00
  #
  #   cb.debit(2_500.00)
  #   cb.available # => 7_500.00
  class CashBalance
    attr_reader :account, :instrument, :available, :reserved,
      :reservations, :old_reservations

    # @!method convert_quantity
    #   @see Instrument#convert_quantity
    delegate :convert_quantity, to: :instrument

    # Initialize a new +CashBalance+.
    #
    # @param account [Account]
    # @param instrument [Instrument]
    def initialize(account, instrument)
      @account = account
      @instrument = instrument
      @available = convert_quantity(0)
      @reserved = convert_quantity(0)
      @reservations = {}
    end

    # Credit funds to the balance.
    #
    # @param amount [String, Numeric] amount to credit
    def credit(amount)
      amount = convert_quantity(amount)

      @available += amount if ensure_positive(amount)
    end

    # Debit funds from the balance.
    #
    # @param amount [String, Numeric] amount to debit
    #
    # @raise [NotEnoughFundsError] if there are not enough funds.
    def debit(amount)
      amount = convert_quantity(amount)

      @available -= amount if ensure_positive(amount) && ensure_at_least(amount)
    end

    # Reserve a specific amount from the available amount.
    #
    # @param amount [String, Numeric] amount to reserve
    #
    # @raise [NotEnoughFundsError] if there are not enough funds
    #
    # @return [String] reservation identifier
    def reserve(amount)
      amount = convert_quantity(amount)

      if ensure_positive(amount) && ensure_at_least(amount)
        reservation = Reservation.new(self, amount)
        @available -= amount
        @reserved += amount
        reservations[reservation.uuid] = reservation

        reservation.uuid
      end
    end


    # Release a specific amount from reserve to available balance.
    #
    # @param reserve_id [String] reservation identifier
    # @param amount [String, Numeric] amount to release
    #
    # @raise [NoSuchReservationError] if there is no reservation with
    # this identified
    #
    # @return [String, nil] reservation identifier if it's not emtpy
    def release(reserve_id, amount = nil)
      if ensure_reservation(reserve_id)
        reservation = reservations[reserve_id]
        amount ||= reservation.remainder
        reservation.release(amount)
        @reserved -= amount
        @available += amount
        delete_reservation(reservation)
      end
    end

    # Debit from reserve balance.
    #
    # @param reserve_id [String] reservation identifier
    # @param amount [String, Numeric] amount to release
    #
    # @raise [NoSuchReservationError] if there is no reservation with
    # this identified
    #
    # @return [String, nil] reservation identifier if it's not emtpy
    def debit_reserved(reserve_id, amount = nil)
      if ensure_reservation(reserve_id)
        reservation = reservations[reserve_id]
        amount ||= reservation.remainder
        reservation.debit(amount)
        @reserved -= amount
        delete_reservation(reservation)
      end
    end

    def as_json
      {
        instrument: instrument.name,
        type: :cash,
        available: Util.number_to_string(available),
        reserved: Util.number_to_string(reserved)
      }
    end

    def inspect
      "#<#{self.class.name} account=#{account.uuid} instrument=#{instrument.name} available=#{Util.number_to_string(available)} reserved=#{Util.number_to_string(reserved)}>"
    end

    def to_s
      "(#{instrument.name} - available: #{Util.number_to_string(available)}, reserved: #{Util.number_to_string(reserved)})"
    end

    private

    # Ensure there is at least `amount` available.
    #
    # @param amount [String, Numeric]
    # @param type [Symbol] +:available+ or +:reserve+
    #
    # @raise [NotEnoughFundsError] if the needed amount is not available
    #
    # @return [Boolean]
    def ensure_at_least(amount, type = :available)
      bucket = type == :available ? available : reserved

      return true if bucket >= convert_quantity(amount)
      raise NotEnoughFundsError,
        "Not enough funds on #{instrument} balance (#{type}: #{bucket}, needed: #{amount})"
    end

    # Ensure a specific reservation exists.
    #
    # @param reservation_id [String] reservation identifier
    #
    # @raise [NotEnoughFundsError] if the reservation exists
    #
    # @return [Boolean]
    def ensure_reservation(reservation_id)
      return true if reservations[reservation_id]
      raise NoSuchReservationError,
        "No reservation with identifier #{reservation_id} exists"
    end

    # Ensure an amount is positive.
    #
    # @raise [NegativeAmountError] if the amount is negative
    #
    # @return [Boolean]
    def ensure_positive(amount)
      return true if amount >= 0
      raise NegativeAmountError,
        "Positive amount expected, but amount passed (#{amount.to_f}) was negative."
    end

    # Move an active reservation to archive if remainder is zero.
    #
    # @param reservation [Reservation]
    def delete_reservation(reservation)
      if reservation.zero?
        reservations.delete(reservation.uuid)
        nil
      else
        reservation.uuid
      end
    end
  end
end
