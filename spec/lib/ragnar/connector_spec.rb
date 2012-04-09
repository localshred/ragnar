require 'spec_helper'
require 'ragnar/connector'

describe Ragnar::Connector do
  include EventedSpec::SpecHelper
  include EventedSpec::AMQPSpec

  before(:each) do
    Ragnar::Connector.connection = nil
  end

  describe '.connect' do

    context 'new configuration methods' do
      it 'can set host and port and have a connection' do
        AMQP.should_receive(:connect).with({:host => Ragnar::Config.host, :port => Ragnar::Config.port})
        Ragnar::Connector.connect
        done
      end
    end

    context 'deprecated configuration methods' do
      before(:each) do
        Ragnar::Connector.host = 'localhost'
        Ragnar::Connector.port = '5762'
      end

      it 'can set host and port and have a connection' do
        host = 'test.md.com'
        port = '5763'

        Ragnar::Connector.host = host
        Ragnar::Connector.port = port

        AMQP.should_receive(:connect).with({host: host, port: port})
        Ragnar::Connector.connect
      end
    end

    it 'uses the existing reactor if it already exists' do
      em do
        EM.should_not_receive(:run)
        Ragnar::Connector.connect
        done
      end
    end

  end

  describe '.connection' do

    it 'stores the connection' do
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
      Ragnar::Connector.connected?.should be_false
      Ragnar::Connector.connect
      delayed(0.3) {
        Ragnar::Connector.connected?.should be_true
        done
      }
    end
  end

end
