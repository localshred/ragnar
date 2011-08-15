require 'spec_helper'
require 'ragnar/connector'
require 'ragnar/exchange'

describe Ragnar::Exchange do
  include EventedSpec::SpecHelper
  include EventedSpec::AMQPSpec
  
  
  describe '.new' do
    it 'creates a channel and exchange' do
      opts = {:durable => true}
      name = 'exch_name'
      
      Ragnar::Connector.should_receive(:connection).and_return(connection = mock('connection'))
      AMQP::Channel.should_receive(:new).with(connection).and_return(channel = mock('channel'))
      channel.should_receive(:topic).with(name, opts)
      Ragnar::Exchange.new(:topic, name, opts)
      done
    end
  end
  
  describe '#queue_prefix' do
    it 'sets a temporary queue prefix' do
      exch = Ragnar::Exchange.new(:topic, 'name')
      exch.queue_prefix = :my_service
      exch.queue_prefix.should == :my_service
      done
    end
  end
  
  describe '#subscribe' do
    let(:exch) { Ragnar::Exchange.new(:topic, 'name') }
    let(:subscription_block) { Proc.new {|m| true } }
    
    it 'binds a queue to the channel and assigns the subscription to the queue' do
      exch.channel.should_receive(:queue).with('the.event.name').and_return(queue = mock('queue'))
      queue.should_receive(:bind).with(exch.exchange, :routing_key => 'the.event.name').and_return(binding = mock('binding'))
      binding.should_receive(:subscribe).with(subscription_block)
      exch.subscribe('the.event.name', subscription_block)
      done
    end
    
    it 'uses the queue_prefix if present when setting the queue name' do
      exch.queue_prefix = :my_service
      exch.channel.should_receive(:queue).with('my_service.the.event.name').and_return(queue = mock('queue'))
      queue.should_receive(:bind).with(exch.exchange, :routing_key => 'the.event.name').and_return(binding = mock('binding'))
      binding.should_receive(:subscribe)
      exch.subscribe('the.event.name')
      done
    end
    
    it 'accepts a hash for queue name and routing key' do
      exch.queue_prefix = :my_service
      exch.channel.should_receive(:queue).with('the.queue.name').and_return(queue = mock('queue'))
      queue.should_receive(:bind).with(exch.exchange, :routing_key => 'the.event.#').and_return(binding = mock('binding'))
      binding.should_receive(:subscribe)
      exch.subscribe(:queue => 'the.queue.name', :routing_key => 'the.event.#')
      done
    end
    
    it 'cannot subscribe if a name is not given' do
      exch.queue_prefix = :my_service
      exch.channel.should_not_receive(:queue)
      expect {
        exch.subscribe(nil)
      }.should raise_error(/Invalid queue name/)
      done
    end
    
    it 'uses' do
      exch.queue_prefix = :my_service
      exch.channel.should_not_receive(:queue)
      expect {
        exch.subscribe(nil)
      }.should raise_error(/Invalid queue name/)
      done
    end
  end
  
  describe '#publish' do
    it 'publishes messages to the exchange' do
      exch = Ragnar::Exchange.new(:topic, 'name')
      publish_opts = {:param => 'value', :routing_key => 'the.event.name'}
      exch.exchange.should_receive(:publish).with('the message', publish_opts)
      exch.publish('the.event.name', 'the message', publish_opts)
      done
    end
  end
  
end