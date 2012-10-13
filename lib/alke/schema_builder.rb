module Alke
  module Schema
    class Parser < BasicObject
      attr_accessor :parsed
      def method_missing(*args)
        @parsed ||= {}
        attribute   = args.shift
        type        = args.shift
        options     = args
        parsed[attribute] = {type: type, options: options}
      end
    end
  end
end
