require 'faraday'

module Alke
  VERSION = '1.0.0'
end

Dir.glob(File.dirname(__FILE__) + '/alke/*.rb') { |file| require file }
