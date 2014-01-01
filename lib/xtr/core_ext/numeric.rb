class Numeric
  # Public: Get a number limited by cap.
  #
  # Examples
  #
  #   10.cap(5) # => 5
  #   2.cap(90) # => 2
  def cap(other)
    self >= other ? other : self
  end
end
