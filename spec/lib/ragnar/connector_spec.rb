require 'spec_helper'
require 'ragnar/connector'

describe Ragnar::Connector do
  include EventedSpec::SpecHelper
  include EventedSpec::AMQPSpec
  
  before(:each) do
    Ragnar::Connector.connection = nil
    Ragnar::Connector.host = 'localhost'
    Ragnar::Connector.port = '5762'
  end
  
  describe '.connect' do
    
    it 'can set host and port and have a connection' do
      host = 'test.md.com'
      port = '5763'
      
      Ragnar::Connector.host = host
      Ragnar::Connector.port = port
      
      AMQP.should_receive(:connect).with({host: host, port: port})
      Ragnar::Connector.connect
      done
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