require 'spec_helper'
require 'ragnar'

describe Ragnar do
  include EventedSpec::SpecHelper
  include EventedSpec::AMQPSpec
  
  describe '.exchange' do
    context 'when the exchange does not exist' do
      it 'creates a new exchange' do
        opts = {:param => 'value'}
        Ragnar::Exchange.should_receive(:new).with(:topic, 'exch_name', opts).and_return(mock('ex', :type => :topic, :name => 'exch_name'))
        Ragnar.exchange(:topic, 'exch_name', opts)
        done
      end
    end
    
    context 'when the exchange already has been created locally' do
      it 'creates a new exchange' do
        exch = Ragnar.exchange(:topic, 'exch_name')
        Ragnar.exchange(:topic, 'exch_name').should_not === exch
        done
      end
    end
    
    context 'when passed a block with embedded subscriptions' do
      it 'registers the subscriptions with the exchange' do
        subscriber = Proc.new{|message| true }
        exchange = Ragnar::Exchange.new(:topic, 'events')
        Ragnar.should_receive(:exchange).and_yield(exchange)
        
        exchange.should_receive(:queue_prefix=).with(:my_service)
        exchange.should_receive(:subscribe).with('the.message.route.1', &subscriber)
        exchange.should_receive(:subscribe).with('the.message.route.2', &subscriber)
        exchange.should_receive(:subscribe).with('the.message.route.3', &subscriber)
        exchange.should_receive(:subscribe).with('the.message.route.4', &subscriber)
        
        Ragnar.exchange(:topic, 'events') do |x|
          x.queue_prefix = :my_service
          x.subscribe('the.message.route.1', &subscriber)
          x.subscribe('the.message.route.2', &subscriber)
          x.subscribe('the.message.route.3', &subscriber)
          x.subscribe('the.message.route.4', &subscriber)
        end
        
        done
      end
    end
  end
  
end