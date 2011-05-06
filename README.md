Ragnar is a client library that aims to provide some top-level helpers for creating AMQP pub/sub code that can be used across many services nodes without having to do a ton of connection/channel handling. This is very much a work in progress, so bear with it.

### Connections ###

Ragnar provides a convenience connector to run EventMachine and setup the AMQP connection. For **Unicorn**, place the connector call inside the `after_fork` block in order to get things going:

    after_fork do |server, worker|
      Ragnar::Connector.connect :host => 'localhost', :port => 5732
    end

### Publishing ###

The following code will publish a message to the 'events' exchange under the routing key 'the.event.name'.

    Ragnar.exchange(:topic, 'events') do |x|
      x.publish('the.event.name', 'this is the message')
    end

And the equivalent AMQP code:

    AMQP.start do |connection, connect_ok|
      channel  = AMQP::Channel.new(connection)
      exchange = channel.topic('events', :auto_delete => false)
      exchange.publish('this is the message', :routing_key => 'the.event.name')
    end


### Subscriptions ###

The following code with Ragnar creates a single topic subscription on the 'events' exchange, using the queue 'myservice.the.event.name' and routing key 'the.event.name'.

    Ragnar.exchange(:topic, 'events') do |x|
      x.queue_prefix = :myservice # optional
      x.subscribe('the.event.name') do |headers, payload|
        # subscription code
      end
      x.subscribe(:queue => 'my.queue', :routing_key => '#.name') do |headers, payload|
        # subscription code
      end
    end
    
The equivalent AMQP code for the code above would be:

    AMQP.start do |connection|
      channel  = AMQP::Channel.new(connection)
      exchange = channel.topic('events', :auto_delete => false)
      channel.queue('myservice.the.event.name').bind(exchange, :routing_key => 'the.event.name').subscribe do |headers, payload|
        # subscription code
      end
      channel.queue('my.queue').bind(exchange, :routing_key => '#.name').subscribe do |headers, payload|
        # subscription code
      end
    end

### Feedback ###

Feedback and comments are welcome:

* Web: [rand9.com][web]
* Twitter: [@localshred][twitter]
* Github: [github][]

Cheers

  [web]: http://www.rand9.com "rand9.com"
  [twitter]: http://twitter.com/localshred "Twitter: @localshred"
  [github]: http://github.com/localshred "Github: localshred"