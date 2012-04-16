# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ragnar/version"

Gem::Specification.new do |s|
  s.name        = "ragnar"
  s.version     = Ragnar::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["BJ Neislen"]
  s.email       = ["bj.neilsen@gmail.com"]
  s.homepage    = "http://www.rand9.com"
  s.summary     = %q{Provide top-level pub/sub methods with RabbitMQ (AMQP) for interacting with a larger service ecosystem}
  s.description = %q{Provide top-level pub/sub methods with RabbitMQ (AMQP) for interacting with a larger service ecosystem}

  s.rubyforge_project = "ragnar"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'amqp', '~>0.7.1'
  s.add_dependency 'bunny'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'evented-spec', '~>0.4.1'
end
