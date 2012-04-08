require 'bunny'
require 'thread'

module Ragnar
  # Simple publishing via a wrapper around bunny
  class SimpleQueue

    def self.options
      @options ||= {
        :host => Ragnar::Config.host,
        :port => Ragnar::Config.port,
        :logging => false
      }
    end

    # Publish to a topic exchange. Defaults to 'events'
    def self.publish_topic(message, route, exchange='events')
      @publish_mutex ||= ::Mutex.new

      @publish_mutex.synchronize do 
        ::Bunny.run(options) do |bunny|
          exchange = bunny.exchange(exchange, :type => :topic)
          exchange.publish(message, :key => route)
        end
      end
    end
  end
end
