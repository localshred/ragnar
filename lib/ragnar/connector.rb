require 'amqp'

# Provide a simple connector piece that runs EM and passes through AMQP connection options
module Ragnar
  class Connector

    class << self

      # Store the connection for later retrieval
      attr_accessor :amqp_connection, :bunny_connection

      # Pass connection options through to AMQP
      def connect(amqp_opts={}, bunny_opts={})
        unless EM.reactor_running?
          Thread.new { EventMachine.run }
          sleep 0.5
        end
        @amqp_connection = ::AMQP.connect(amqp_opts)
        bunny_opts = bunny_opts.length <= 0 ? amqp_opts : bunny_opts
        @bunny_connection = ::Bunny.new(bunny_opts)
        @bunny_connection.start
      end

      def amqp_connected?
        @amqp_connection && @amqp_connection.connected?
      end

      def bunny_connected?
        @bunny_connection && @bunny_connection.connected?
      end
    end

  end
end
