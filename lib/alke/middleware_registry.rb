module Alke
  class MiddlewareRegistry

    def initialize(instance)
      @connection   = instance.connection
      @builder      = instance.connection.builder
      @adapter      = instance.class.adapter
    end

    def update(&blk)
      instance_exec(@connection, &blk)
    end

    private

    def with(middleware, *args)
      options = {}
      options = options.merge(args.pop) if args.last.is_a?(Hash)
      if options[:before]
        @builder.insert_before  options[:before], middleware, *args
      elsif options[:after]
        @builder.insert_after   options[:after], middleware, *args
      else
        @builder.insert_before  @adapter, middleware, *args
      end
    end
  end
end
