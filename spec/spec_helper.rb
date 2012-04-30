require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'evented-spec'
require 'eventmachine'

unless EM.reactor_running?
  Thread.new { EventMachine.run }
  Thread.pass until EM.reactor_running?
end

$: << File.expand_path('../lib', File.dirname(__FILE__))
