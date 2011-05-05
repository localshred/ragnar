require 'spec_helper'
require 'ragnar/connector'

describe Ragnar::Connector do
  
  describe '.connect' do
    
    it 'creates a connection to AMQP' do
      AMQP.should_receive(:connect)
      Ragnar::Connector.connect
    end
  
  end
  
end