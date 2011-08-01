require 'ragnar/connector'
require 'ragnar/exchange'

module Ragnar
  
  module_function
  
  def exchange type, name, options={}
    x = Ragnar::Exchange.new(type, name, options)
    yield(x) if block_given?
    x
  end
  
end
