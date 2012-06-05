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

    # Note this method does not bind a queue to an exchange, therefore it's
    # required that the queue/exchange are already bound before calling this
    # method
    def self.publish(message, route, exchange, opts={})
      # delete the exchange type from the options or set it to topic
      exchange_type = opts.delete(:exchange_type) { 'topic' }
      @publish_mutex ||= ::Mutex.new

      @publish_mutex.synchronize do
        ::Bunny.run(options) do |bunny|
          exchange = bunny.exchange(exchange, :type => exchange_type)
          exchange.publish(message, opts.merge(:key => route))
        end
      end
    end
  end
end
