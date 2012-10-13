module Alke
  module Client
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

    module ClassMethods
      def adapter(adapter = nil)
        return @adapter ||= Faraday::Adapter::NetHttp if adapter.nil?
        @adapter = adapter
      end

      def host(host = nil)
        return @host.to_s if host.nil?
        @host = host
      end

      def prefix(prefix = nil)
        return @prefix.to_s if prefix.nil?
        @prefix = prefix
      end

      def path(path = nil)
        return @path.to_s if path.nil?
        @path = path
      end

      def url(id = nil)
        url = prefix + path
        url += "/#{id}" if id
        url
      end

      def connection
        @connection ||= Faraday.new(url: host) do |builder|
          # build default stack
          builder.use adapter
        end
        @connection.dup
      end

      def schema(&block)
        parser = Alke::Schema::Parser.new
        parser.instance_eval &block
        @__schema_raw__ = parser.parsed
        @__schema__ = Array.new
        @__schema_raw__.each do |attribute, options|
          attr_accessor attribute
          @__schema__ << "@#{attribute}"
        end
      end

      def [](id, params = {})
        connection.get do |req|
          req.url url(id), params
        end
      end
    end

    module InstanceMethods
      
    end
    
  end
end
