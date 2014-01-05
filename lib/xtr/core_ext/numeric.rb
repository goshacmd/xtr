class Numeric
  # Get a number limited by cap.
  #
  # @example
  #   10.cap(5) # => 5
  #   2.cap(90) # => 2
  def cap(other)
    self >= other ? other : self
  end
end
