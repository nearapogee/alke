# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :git
Hoe.plugin :isolate
Hoe.plugin :minitest

Hoe.spec 'alke' do
  developer("Matt Smith", "matt@nearapogee.com")

  dependency('faraday', '~> 0.8.0')
  dependency('json', '~> 1.7.5')
  dependency('isolate', '~> 3.2.2', :dev)
  dependency('sinatra', '~> 1.3.3', :dev)
  dependency('sinatra-contrib', '~> 1.3.1', :dev)
  dependency('sequel', '~> 3.4.0', :dev)
end

# vim: syntax=ruby
