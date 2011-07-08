module Ragnar
  module AMQP
    class Exchange

      attr_reader :exchange, :channel, :type, :name, :options

      def initialize type, name, opts={}
        @type, @name, @options = type, name, opts
        @channel = ::AMQP::Channel.new(Ragnar::Connector.amqp_connection)
        @exchange = @channel.__send__(@type, @name, @options)
      end

      # def publish_multiple routing_key, messages, opts={}
        # EM.schedule do
          # @exchange.publish(message, opts.merge(:routing_key => routing_key))
        # end
        # sleep 0.1
      # end

      # Takes a subscription key or queue/routing options
      #
      #   exchange.subscribe('the.key') # => queue name and routing key are 'the.key'
      #   exchange.subscribe(:queue => 'my.queue', :routing_key => 'message.*.pattern')
      #
      def subscribe name, subscribe_opts={}, &block
        subscription = proc {
          if name.is_a?(Hash)
            queue_name = name[:queue] or raise 'Invalid queue name'
            routing_key = name[:routing_key]
          else
            raise 'Invalid queue name' if name.nil? or name.strip.empty?
            queue_name = queue_prefix.nil? ? name : '%s.%s' % [queue_prefix, name]
            routing_key = name
          end

          # we use threads, schedule is thread safe
            @channel.queue(queue_name).bind(@exchange, :routing_key => routing_key).
              subscribe(subscribe_opts, &block) unless(@channel.queue(queue_name).subscribed?)
        }
        EM.defer(subscription)
      end
    end
  end
end
