module Xtr
  # A journal of user operations.
  #
  # @abstract Subclass and override {#record} and {#replay}.
  class Journal
    class << self
      # Build a journal instance.
      #
      # @param type [String, Symbol] journal type
      # @param args [Array] journal initializer arguments
      # @return [Journal]
      def build(type, *args)
        klass = const_get(type.to_s.capitalize)
        args.empty? ? klass.new : klass.new(*args)
      end
    end

    # Record a user operation.
    #
    # @param op [Operation] operation to record
    # @return [void]
    def record(op)
      raise NotImplementedError
    end

    # Replay journal operations.
    #
    # @param op_interface [#execute_op] operation interface used to
    #   execute journaled operations
    # @return [void]
    def replay(op_interface)
      raise NotImplementedError
    end

    # Dummy journal. Does nothing.
    class Dummy < Journal
      # (see Journal#record)
      def record(op)
      end

      # (see Journal#replay)
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

      # (see Journal#record)
      def record(op)
        file.puts Marshal.dump(op), "\n"
      end

      # (see Journal#replay)
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
