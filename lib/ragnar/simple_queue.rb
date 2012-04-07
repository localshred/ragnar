require 'bunny'
module Ragnar
  # Simple publishing via a wrapper around bunny
  class SimpleQueue
    attr_reader :bunny

    def initialize
      @bunny = Bunny.new({:host => Ragnar::Config.host,
                          :port => Ragnar::Config.port,
                          :logging => false})
    end

    # Publish to a topic exchange. Defaults to 'events'
    def self.publish_topic(message, route, exchange='events')
      @sq = Ragnar::SimpleQueue.new
      @sq.publish_topic(message, route, exchange)
    end

    def publish_topic(message, route, exchange)
      ensure_connection
      exchange = @bunny.exchange(exchange, :type => :topic)
      exchange.publish(message, :key => route)
    end

    private
      def ensure_connection
        unless(@bunny.connected?)
          @bunny.stop
          @bunny.start
        end
      end
  end
end
