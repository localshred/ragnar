require 'spec_helper'
require 'ragnar'
require 'ragnar/simple_queue'

describe Ragnar::SimpleQueue do
  describe '#publish' do
    let(:bunny_exchange) do
      m = mock
      m.stub(:exchange)
      m
    end

    let(:bunny_mock) do
      bm = mock('Bunny')
      bm.stub(:setup)
      bm.stub(:stop)
      bm.stub(:connected?)
      bm.stub(:start)
      bm.stub(:exchange).and_return(bunny_exchange)
      bm
    end

    before(:each) { ::Bunny.stub(:run).and_yield(bunny_mock) }

    it 'publishes a message' do
      message = 'publish me'
      route = 'to.the.batcave'
      bunny_exchange.should_receive(:publish).with(message, {:key => route})
      described_class.publish(message, route, 'event_exchange')
    end

    it 'sends all options on to bunny' do
      message = 'publish me'
      route = 'to.the.batcave'
      options = {:priority => 10, :bad => 'option'}
      bunny_exchange.should_receive(:publish).with(message, options.merge(:key => route))
      described_class.publish(message, route, 'event_exchange', options)
    end
  end
end
