module Xtr
  class NotEnoughFundsException < RuntimeError; end
  class NoSuchReservationException < RuntimeError; end
  class NegativeAmountException < RuntimeError; end

  # Public: A currency balance of an account.
  #
  # Examples
  #
  #   cb = CurrencyBalance.new acc, :USD
  #   cb.credit(10_000.00)
  #   cb.available # => 10_000.00
  #
  #   cb.debit(2_500.00)
  #   cb.available # => 7_500.00
  class CurrencyBalance
    attr_reader :account, :currency, :available, :reserved,
      :reservations, :old_reservations

    # Public: Initialize a balance.
    #
    # account  - The account.
    # currency - The Symbol currency code.
    def initialize(account, currency)
      @account = account
      @currency = currency
      @available = Util.zero
      @reserved = Util.zero
      @reservations = {}
      @old_reservations = {}
    end

    # Public: Credit funds to the balance.
    #
    # amount - The BigDecimal amount to credit.
    def credit(amount)
      amount = Util.big_decimal(amount)

      @available += amount if ensure_positive(amount)
    end

    # Public: Debit funds from the balance.
    #
    # amount - The BigDecimal amount to debit.
    #
    # Raises NotEnoughFundsException if there are not enough funds.
    def debit(amount)
      amount = Util.big_decimal(amount)

      @available -= amount if ensure_positive(amount) && ensure_at_least(amount)
    end

    # Public: Reserve a specific amount from the available amount.
    #
    # amount - The BigDecimal amount to reserve.
    #
    # Returns a String reservation identifier.
    # Raises NotEnoughFundsException if there are not enough funds.
    def reserve(amount)
      amount = Util.big_decimal(amount)

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
    # amount     - The optional BigDecimal amount to release. If not
    #              passed, all remaining funds will be released.
    #
    # Raises NoSuchReservationException if no reservation with this identifier
    # was found.
    def release(reserve_id, amount = nil)
      if ensure_reservation(reserve_id)
        reservation = reservations[reserve_id]
        return unless reservation # old reservation
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
    # amount     - The optional BigDecimal amount to debit. If not
    #              passed, all remaining funds will be debited.
    #
    # Raises NoSuchReservationException if no reservation with this identifier
    # was found.
    def debit_reserved(reserve_id, amount = nil)
      if ensure_reservation(reserve_id)
        reservation = reservations[reserve_id]
        return unless reservation
        amount ||= reservation.remainder
        reservation.debit(amount)
        @reserved -= amount
        @reservations.delete(reserve_id) if reservation.zero?
        delete_reservation(reservation)
      end
    end

    def inspect
      "#<#{self.class.name} account=#{account.uuid} currency=#{currency} available=#{available} reserved=#{reserved}>"
    end

    def to_s
      "(#{currency} - available: #{available.to_f}, reserved: #{reserved.to_f})"
    end

    private

    # Private: Ensure there is at least `amount` available.
    #
    # amount - The BigDecimal amount to check against.
    # type   - The bucket to check against (default :available).
    #          Possible values: :available, :reserve.
    #
    # Returns true if the needed amount is available.
    # Raises NotEnoughFundsException otherwise.
    def ensure_at_least(amount, type = :available)
      bucket = type == :available ? available : reserved

      return true if bucket >= Util.big_decimal(amount)
      raise NotEnoughFundsException,
        "Not enough funds on #{currency} balance (#{type}: #{bucket}, needed: #{amount})"
    end

    # Private: Ensure a specific reservation exists.
    #
    # reserve_id - The String reservation identifier.
    #
    # Returns true if the reservation exists.
    # Raises NoSuchReservationException otherwise.
    def ensure_reservation(reservation_id)
      reservation = reservations[reservation_id]
      old_reservation = old_reservations[reservation_id]

      return true if reservation || old_reservation
      raise NoSuchReservationException,
        "No reservation with identifier #{reservation_id} exists"
    end

    # Private: Ensure an amount is positive.
    #
    # Returns true if it is.
    # Raises NegativeAmountException otherwise.
    def ensure_positive(amount)
      return true if amount >= Util.zero
      raise NegativeAmountException,
        "Positive amount expected, but amount passed (#{amount.to_f}) was negative."
    end

    # Private: Move an active reservation to archive if remainder is zero.
    def delete_reservation(reservation)
      if reservation.zero?
        reservations.delete(reservation.uuid)
        old_reservations[reservation.uuid] = reservation
      end
    end
  end
end
