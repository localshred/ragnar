require 'spec_helper'
require 'ragnar/connector'

describe Ragnar::Connector do
  include EventedSpec::SpecHelper
  include EventedSpec::AMQPSpec
  
  before(:each) do
    Ragnar::Connector.connection = nil
  end
  
  describe '.connect' do
    
    it 'runs eventmachine and creates an AMQP connection' do
      connection = Ragnar::Connector.connect
      delayed(0.3) {
        EM.reactor_running?.should be_true
        connection.should be_connected
        done
      }
    end
    
    it 'accepts an options hash and passes it through' do
      opts = {:host => 'localhost', :port => '5762'}
      AMQP.should_receive(:connect).with(opts)
      Ragnar::Connector.connect(opts)
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