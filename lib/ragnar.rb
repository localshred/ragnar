require 'ragnar/connector'
require 'ragnar/exchange'

module Ragnar
  
  module_function
  
  def exchange type, name, options={}
    exch = exchanges[key(type, name)] || store(Ragnar::Exchange.new(type, name, options))
    yield(exch) if block_given?
    exch
  end

  def store ex
    exchanges[key(ex.type, ex.name)] = ex
  end

  def exchanges
    @exchanges ||= {}
  end
  
  def key type, name
    '%s-%s' % [type.to_s, name]
  end
  
  private :store, :exchanges, :key
  
end