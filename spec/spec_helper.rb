require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'evented-spec'
require 'eventmachine'

unless EM.reactor_running?
  Thread.new { EventMachine.run }
  sleep 0.5
end

$: << File.expand_path('../lib', File.dirname(__FILE__))