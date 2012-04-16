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

describe Ragnar::Config do
  subject { Ragnar::Config }

  describe '.config' do
    subject { Ragnar::Config.config }
    specify { subject.should include(:logger) }
    specify { subject.should include(:env) }
    specify { subject.should include(:host) }
    specify { subject.should include(:port) }
  end

  describe '.valid_key?' do
    # purely for --format=documentation output
    matcher :return_true_for do |expected|
      match {|actual| subject.valid_key?(expected) == true }
    end

    it { should return_true_for(:logger) }
    it { should return_true_for(:env) }
    it { should return_true_for(:host) }
    it { should return_true_for(:port) }
    it %{returns false on invalid keys} do
      subject.valid_key?(:invalid_key).should be_false
    end
  end

  describe '.restore_defaults!' do
    before(:each) do
      subject.configure do |c|
        c.env = :untested
      end
    end

    describe 'env' do
      specify { subject.env.should eq(:untested) }
      it 'changes the env back to default' do
        subject.restore_defaults!
        subject.env.should eq(:development)
      end
    end
  end

  describe '.method_missing' do
    before(:each) { subject.restore_defaults! }
    context 'when key is valid' do
      it 'returns the data for that key' do
        subject.env.should eq(:development)
      end
    end

    context 'when key is not valid' do
      it 'raises method missing' do
        expect { subject.invalid_key }.to raise_error
      end
    end

    context 'when key is a setter' do
      it 'sets the value correctly' do
        subject.env = :something_else
        subject.env.should eq(:something_else)
      end
    end

    context 'when key is a getter' do
      describe 'env' do
        specify { subject.env.should eq(:development) }
      end
    end
  end
end
  
