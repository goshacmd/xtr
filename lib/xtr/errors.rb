module Xtr
  # Generic Xtr error class.
  class XtrError < StandardError; end

  # Raised when trying to get the balance in unsupported instrument.
  class UnsupportedInstrumentrror < XtrError; end

  # Raised when trying to reserve or debit amount larger than the balance.
  class NotEnoughFundsError < XtrError; end

  # Raised when trying to operate on reserve with invalid ID.
  class NoSuchReservationError < XtrError; end

  # Raised when trying to do balance operations with a negative amount.
  class NegativeAmountError < XtrError; end

  # Raised when trying to debit or release from reserve amount larger than reserve.
  class NotEnoughFundsReservedError < XtrError; end

  # Raised when trying to execute an unknown operation.
  class NoSuchOperationError < XtrError; end
end
