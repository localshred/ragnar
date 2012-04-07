require 'spec_helper'
require 'ragnar'
require 'ragnar/simple_queue'

describe Ragnar::SimpleQueue do
  describe '#publish_topic' do
    let(:bunny_exchange) do
      m = mock
      m.stub(:exchange)
      m
    end

    let(:bunny_mock) do
      bm = mock('bunny')
      bm.stub(:stop)
      bm.stub(:connected?)
      bm.stub(:start)
      bm.stub(:exchange).and_return(bunny_exchange)
      bm
    end

    before(:each) { Bunny.stub(:new).and_return(bunny_mock) }

    it %{publishes a message} do
      message = 'publish me'
      route = 'to.the.batcave'
      bunny_exchange.should_receive(:publish).with(message, {:key => route})
      described_class.publish_topic(message, route)
    end

  end
end
