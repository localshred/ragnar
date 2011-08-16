require 'amqp'

# Provide a simple connector piece that runs EM and passes through AMQP connection options
module Ragnar
  class Connector
    
    class << self
      
      # Store the connection for later retrieval
      attr_accessor :connection
      attr_accessor :host
      attr_accessor :port
      
      
      # Pass connection options through to AMQP
      def connect
        @connection = AMQP.connect({host: @host || 'localhost', port: @port || 5762})
      end
      
      def connected?
        @connection && @connection.connected?
      end
    
    end
    
  end
end