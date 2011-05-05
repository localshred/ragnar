require 'amqp'

# Provide a simple connector piece that runs EM and passes through AMQP connection options
module Ragnar
  class Connector
    
    class << self
      
      # Store the connection for later retrieval
      attr_accessor :connection
      
      # Pass connection options through to AMQP
      def connect opts={}
        unless EM.reactor_running?
          Thread.new { EventMachine.run }
          sleep 0.5
        end
        @connection = AMQP.connect(opts)
      end
      
      def connected?
        @connection && @connection.connected?
      end
    
    end
    
  end
end