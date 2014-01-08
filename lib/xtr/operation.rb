module Xtr
  # User operation.
  class Operation < Struct.new(:serial, :name, :args)
    # @!attribute serial
    #   @return [Integer] operation serial number
    # @!attribute name
    #   @return [String] operation name
    # @!attribute args
    #   @return [Array] operation arguments
  end
end
