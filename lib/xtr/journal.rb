module Xtr
  # A journal of user operations.
  #
  # @abstract
  class Journal
    # Record a user operation.
    #
    # @abstract
    #
    # @param op [Operation]
    def record(op)
      raise NotImplementedError
    end

    # Dummy journal. Does nothing.
    class Dummy < Journal
      def record(op)
      end
    end

    # File-based journal implementation.
    class File < Journal
      attr_reader :file

      # Initialize a new +File+ journal.
      #
      # @param filename [String] file name
      def initialize(filename)
        @file = ::File.new(filename, 'a+')
      end

      def record(op)
        file.puts Marshal.dump(op)
      end
    end
  end
end
