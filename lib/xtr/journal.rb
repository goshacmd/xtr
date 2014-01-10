module Xtr
  # A journal of user operations.
  #
  # @abstract
  class Journal
    class << self
      # Build a journal instance.
      #
      # @param type [String, Symbol] journal type
      # @param args [Array] journal initializer arguments
      def build(type, *args)
        klass = const_get(type.to_s.capitalize)
        args.empty? ? klass.new : klass.new(*args)
      end
    end

    # Record a user operation.
    #
    # @abstract
    #
    # @param op [Operation]
    def record(op)
      raise NotImplementedError
    end

    # Replay journal operations.
    #
    # @param op_interface [#execute_op] operation interface used to
    # execute journaled operations
    def replay(op_interface)
      raise NotImplementedError
    end

    # Dummy journal. Does nothing.
    class Dummy < Journal
      def record(op)
      end

      def replay(op_interface)
      end
    end

    # File-based journal implementation.
    class File < Journal
      attr_reader :file

      # Initialize a new +File+ journal.
      #
      # @param filename [String] file name
      def initialize(filename)
        dir = ::File.dirname filename
        FileUtils.mkdir_p dir
        @file = ::File.new filename, 'a+'
      end

      def record(op)
        file.puts Marshal.dump(op), "\n"
      end

      def replay(op_interface)
        file.each_line("\n\n") do |line|
          op = Marshal.load(line)
          Xtr.logger.debug "replaying #{op}"
          op_interface.execute_op(op)
        end
      end
    end
  end
end
