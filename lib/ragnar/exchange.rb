module Ragnar
  class Exchange

    attr_reader :exchange, :channel, :type, :name, :options
    attr_accessor :queue_prefix

    def initialize type, name, opts={}
      @type, @name, @options = type, name, opts
    end

    def publish routing_key, message, opts={}
      EM.schedule do
        Ragnar::Connector.connect unless Ragnar::Connector.connected?

        connection = Ragnar::Connector.connection
        channel = AMQP::Channel.new(connection)
        exchange = channel.__send__(@type, @name, @options)

        channel.queue(@name).bind(exchange, opts.merge(routing_key: routing_key))
        exchange.publish(message, opts.merge(:routing_key => routing_key))
      end
    end

    # Takes a subscription key or queue/routing options
    #
    #   exchange.subscribe('the.key') # => queue name and routing key are 'the.key'
    #   exchange.subscribe(:queue => 'my.queue', :routing_key => 'message.*.pattern')
    #
    def subscribe name, subscribe_opts={}, &block
      if name.is_a?(Hash)
        queue_name = name[:queue] or raise 'Invalid queue name'
        routing_key = name[:routing_key]
      else
        raise 'Invalid queue name' if name.nil? or name.strip.empty?
        queue_name = queue_prefix.nil? ? name : '%s.%s' % [queue_prefix, name]
        routing_key = name
      end

      EM.schedule do
        Ragnar::Connector.connect unless Ragnar::Connector.connected?

        connection = Ragnar::Connector.connection
        channel = AMQP::Channel.new(connection)
        exchange = channel.__send__(@type, @name, @options)

        channel.queue(queue_name).bind(exchange, :routing_key => routing_key).subscribe(subscribe_opts, &block)
      end
    end
  end
end
