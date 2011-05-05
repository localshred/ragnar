module Ragnar
  class Exchange
    
    attr_reader :exchange, :channel, :type, :name, :options
    attr_accessor :queue_prefix
    
    def initialize type, name, opts={}
      @type, @name, @options = type, name, opts
      @channel = AMQP::Channel.new(Ragnar::Connector.connection)
      @exchange = @channel.__send__(@type, @name, @options)
    end
    
    def publish routing_key, message, opts={}
      @exchange.publish(message, opts.merge(:routing_key => routing_key))
    end
    
    def subscribe name, opts={}, &block
      @channel.queue(queue_name(name)).bind(@exchange, :routing_key => name).subscribe(opts, &block)
    end
    
    private
    
    def queue_name name
      queue_prefix.nil? ? name : '%s.%s' % [queue_prefix, name]
    end
    
  end
end