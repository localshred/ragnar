module Ragnar
  module Bunny
    class Exchange

      attr_reader :exchange, :channel, :type, :name, :options

      def initialize type, name, opts={}
        @queue = Ragnar::Connector.bunny_connection.queue(name)
        @exchange = Ragnar::Connector.bunny_connection.exchange(name, type: type)
        @queue.bind(@exchange, key: opts[:routing_key])
      end

      def publish routing_key, message, opts={}
        @exchange.publish(message, opts.merge(key: routing_key))
      end
    end
  end
end
