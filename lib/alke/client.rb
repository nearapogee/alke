module Alke
  module Client
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

    module ClassMethods
      def adapter(adapter = nil)
        @adapter ||= adapter || Faraday::Adapter::NetHttp
      end

      def host(host = nil)
        @host ||= host
      end

      def prefix(prefix = nil)
        @prefix ||= prefix
      end

      def path(path = nil)
        @path ||= path
      end

      def url(id = nil)
        url = String.new
        url += prefix.to_s
        url += path.to_s
        url += "/#{id}" if id
        url
      end

      # Public: Create and cache a connection with the default
      # middleware stack.
      #
      # Returns a connection.
      def connection
        @connection ||= Faraday.new(url: host) do |builder|
          builder.use Alke::JsonParser
          builder.use adapter
        end
        @connection.dup
      end

      def schema(&block)
        parser = Alke::Schema::Parser.new
        parser.instance_eval &block
        @__parsed_schema__ = parser.parsed
        @__write_attributes__ = Array.new
        @__parsed_schema__.each do |attribute, options|
          @__write_attributes__ << attribute unless options[:readonly] ||
            options[:type] == :primary_key
          def_attribute attribute, options
        end
      end

      def def_attribute(attribute, options)
        case options[:type]
        when :datetime
          def_datetime(attribute, options)
        when :file
          # UploadIO
        when :primary_key
          attr_reader attribute
        else
          options[:readonly] ? attr_reader(attribute) : \
            attr_accessor(attribute)
        end
      end

      def def_datetime(attribute, options)
        require 'date'
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{attribute}
            if [DateTime, Time, Date].include? datetime.class
              return @#{attribute}
            end
            @#{attribute} = DateTime.parse(@#{attribute}.to_s)
          end
        RUBY
        return if options[:readonly]

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{attribute}=(datetime)
            if [DateTime, Time, Date].include? datetime.class
              return @#{attribute} = datetime
            end
            @#{attribute} = DateTime.parse(datetime.to_s)
          end
        RUBY
      end

      def [](id, params = {})
        response = connection.get do |req|
          req.url url(id), params
        end
        new(response.body)
      end

      def create(attributes = {})
        new(attributes).tap {|x| x.save }
      end
    end

    module InstanceMethods
      def initialize(attributes = {})
        unserialize(attributes)
      end

      def save
        response = self.class.connection.post do |req|
          req.url self.class.url(id)
          req.body = self.writable_attributes
        end
        unserialize(response.body)
      end

      def unserialize(data = {})
        data.each do |key, value|
          singleton_class.send :attr_reader, key unless respond_to?(key)
          instance_variable_set "@#{key}", value
        end
      end

      def writable_attributes
        attrs = self.class.instance_variable_get("@__write_attributes__")
        writable_attributes = Hash.new
        attrs.each do |attr|
          writable_attributes[attr] = send(attr)
        end
        writable_attributes
      end

      def persisted?
        !id.nil?
      end
    end
    
  end
end
