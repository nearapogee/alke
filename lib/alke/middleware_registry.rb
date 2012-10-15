module Alke
  class MiddlewareRegistry

    def initialize(connection)
      @connection = connection
    end

    def update(block)
      instance_exec(@connection, block)
    end
    
  end
end
