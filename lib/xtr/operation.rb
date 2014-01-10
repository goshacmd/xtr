module Xtr
  # User operation.
  class Operation < Struct.new(:serial, :time, :name, :args)
    # @!attribute serial
    #   @return [Integer] operation serial number
    # @!attribute time
    #   @return [Time] time operation was executed
    # @!attribute name
    #   @return [String] operation name
    # @!attribute args
    #   @return [Array] operation arguments
  end
end
