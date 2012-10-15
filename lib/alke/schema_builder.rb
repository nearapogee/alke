module Alke
  module Schema
    class Parser < BasicObject
      attr_accessor :parsed
      def method_missing(*args)
        @parsed           ||= {}
        attribute         = args.shift
        type              = args.shift
        options           = args.shift || {}
        parsed[attribute] = options.merge(type: type)
      end
    end
  end
end
