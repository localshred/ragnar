require 'spec_helper'
require 'ragnar.rb'

describe Ragnar::Connector do
  include EventedSpec::SpecHelper
  include EventedSpec::AMQPSpec

  before(:all) { EM.stop_event_loop; sleep(0.3) }
  after(:all) { Thread.new { EM.run }; Thread.pass until EM.reactor_running? }

  before(:each) do
    Ragnar::Connector.connection = nil
    Ragnar::Connector.host = nil
    Ragnar::Connector.port = nil
  end

  describe '.connect' do

    context 'new configuration methods' do
      it 'can set host and port and have a connection' do
        AMQP.stub(:connect)
        AMQP.should_receive(:connect).with({:host => Ragnar::Config.host, :port => Ragnar::Config.port})
        Ragnar::Connector.connect
        done
      end
    end

    context 'deprecated configuration methods' do

      it 'can set host and port and have a connection' do
        AMQP.stub(:connect)
        host = 'test.md.com'
        port = '5763'

        Ragnar::Connector.host = host
        Ragnar::Connector.port = port

        AMQP.should_receive(:connect).with({host: host, port: port})
        Ragnar::Connector.connect
        done
      end
    end

    context 'new configuration methods' do
      it 'can set host and port and have a connection' do
        AMQP.stub(:connect)
        host = 'test2.md.com'
        port = '5763'

        Ragnar::Connector.host = nil
        Ragnar::Connector.port = nil

        Ragnar::Config.configure do |c|
          c.host = host
          c.port = port
        end

        AMQP.should_receive(:connect).with({host: host, port: port})
        Ragnar::Connector.connect
        done
      end
    end

    it 'uses the existing reactor if it already exists' do
      AMQP.stub(:connect)
      em do
        EM.should_not_receive(:run)
        Ragnar::Connector.connect
        done
      end
    end

  end

  describe '.connection' do

    it 'stores the connection' do
      AMQP.stub(:connect).and_return(double("connection", :connected? => true))
      Ragnar::Connector.connect
      delayed(0.3) {
        Ragnar::Connector.connection.should be_connected
        done
      }
    end

    it 'does not create the connection for you' do
      AMQP.should_not_receive(:connect)
      Ragnar::Connector.connection.should be_nil
      done
    end

  end

  describe '.connected?' do
    it 'relays connection state' do
      AMQP.stub(:connect).and_return(double("connection", :connected? => true))
      Ragnar::Connector.connected?.should be_false
      Ragnar::Connector.connect
      delayed(0.3) {
        Ragnar::Connector.connected?.should be_true
        done
      }
    end
  end

end
