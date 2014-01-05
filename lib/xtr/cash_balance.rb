module Xtr
  # Public: A cash balance of an account.
  #
  # Examples
  #
  #   cb = CashBalance.new acc, USD
  #   cb.credit(10_000.00)
  #   cb.available # => 10_000.00
  #
  #   cb.debit(2_500.00)
  #   cb.available # => 7_500.00
  class CashBalance
    attr_reader :account, :instrument, :available, :reserved,
      :reservations, :old_reservations

    delegate :convert_quantity, to: :instrument

    # Public: Initialize a balance.
    #
    # account    - The account.
    # instrument - The Instrument instance.
    def initialize(account, instrument)
      @account = account
      @instrument = instrument
      @available = convert_quantity(0)
      @reserved = convert_quantity(0)
      @reservations = {}
    end

    # Public: Credit funds to the balance.
    #
    # amount - The amount to credit.
    def credit(amount)
      amount = convert_quantity(amount)

      @available += amount if ensure_positive(amount)
    end

    # Public: Debit funds from the balance.
    #
    # amount - The amount to debit.
    #
    # Raises NotEnoughFundsError if there are not enough funds.
    def debit(amount)
      amount = convert_quantity(amount)

      @available -= amount if ensure_positive(amount) && ensure_at_least(amount)
    end

    # Public: Reserve a specific amount from the available amount.
    #
    # amount - The amount to reserve.
    #
    # Returns a String reservation identifier.
    # Raises NotEnoughFundsError if there are not enough funds.
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


    # Public: Release a specific amount from reserve to available
    # balance.
    #
    # reserve_id - The String reservation identifier.
    # amount     - The optional amount to release. If not
    #              passed, all remaining funds will be released.
    #
    # Raises NoSuchReservationError if no reservation with this identifier
    # was found.
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

    # Public: Debit from reserve balance.
    #
    # reserve_id - The String reservation identifier.
    # amount     - The optional amount to debit. If not
    #              passed, all remaining funds will be debited.
    #
    # Raises NoSuchReservationError if no reservation with this identifier
    # was found.
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

    # Private: Ensure there is at least `amount` available.
    #
    # amount - The amount to check against.
    # type   - The bucket to check against (default :available).
    #          Possible values: :available, :reserve.
    #
    # Returns true if the needed amount is available.
    # Raises NotEnoughFundsError otherwise.
    def ensure_at_least(amount, type = :available)
      bucket = type == :available ? available : reserved

      return true if bucket >= convert_quantity(amount)
      raise NotEnoughFundsError,
        "Not enough funds on #{instrument} balance (#{type}: #{bucket}, needed: #{amount})"
    end

    # Private: Ensure a specific reservation exists.
    #
    # reserve_id - The String reservation identifier.
    #
    # Returns true if the reservation exists.
    # Raises NoSuchReservationError otherwise.
    def ensure_reservation(reservation_id)
      return true if reservations[reservation_id]
      raise NoSuchReservationError,
        "No reservation with identifier #{reservation_id} exists"
    end

    # Private: Ensure an amount is positive.
    #
    # Returns true if it is.
    # Raises NegativeAmountError otherwise.
    def ensure_positive(amount)
      return true if amount >= 0
      raise NegativeAmountError,
        "Positive amount expected, but amount passed (#{amount.to_f}) was negative."
    end

    # Private: Move an active reservation to archive if remainder is zero.
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
