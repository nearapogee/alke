require 'json'

module Alke
  class JsonParser < Faraday::Middleware
    CONTENT_TYPE  = 'Content-Type'.freeze
    MIME_TYPE     = 'application/json'.freeze

    def call(env)
      env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE
      env[:body] = (env[:body] || {}).to_json
      @app.call(env).on_complete do
        env[:body] = JSON.parse(env[:body])
      end
    end
  end
end
