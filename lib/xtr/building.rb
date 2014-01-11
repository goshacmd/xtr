module Xtr
  # A module to lookup and build subclasses of some class.
  #
  # @example
  #   class Thing
  #     extend Building
  #
  #     class First < Thing; end
  #     class Second < Thing; end
  #   end
  #
  #   Thing.lookup(:first) # => Thing::First
  #   Thing.build(:first) # => #<Thing::First:0x1337>
  module Building
    # Lookup subclass inside this class with name of +name+.
    #
    # @param name [String]
    # @return [Class]
    def lookup(name)
      name = name.to_s.downcase.camelize
      const_get(name)
    rescue NameError
      raise NoSuchSubclassError,
        "No #{self.name.downcase} named #{name} was found"
    end

    # Build an object.
    #
    # @param name [String]
    # @param args [Array] object initializer arguments
    # @return [Object]
    def build(name, *args)
      lookup(name).new(*args)
    end
  end
end
