require 'logger'
require 'ostruct'
require 'ragnar/connector'
require 'ragnar/exchange'

module Ragnar

  module_function

  def exchange type, name, options={}
    x = Ragnar::Exchange.new(type, name, options)
    yield(x) if block_given?
    x
  end

  # Set all your configuration options.
  #   log_conf = YAML.load_file(Rails.root.join('config/gelf_logger.yml'))[Rails.env]
  #   Ragnar::Config.configure do |c|
  #     c.env    = 'environment'
  #     c.logger = logger_instance
  #     c.host   = 'localhost'
  #     c.port   = 5672
  #   end
  #
  # If no logger is defined, the default will be set to Logger and output will be
  # directed to STDOUT
  class Config
    @config = OpenStruct.new

    def self.configure
      yield self
    end

    def self.config
      @config.instance_variable_get(:@table)
    end

    def self.valid_key?(key)
      [ :logger,
        :env,
        :host,
        :port ].include?(key)
    end

    def self.restore_defaults!
      self.configure do |c|
        c.logger = Logger.new(STDOUT)
        c.env    = :development
        c.host   = 'localhost'
        c.port   = 5672
      end
    end

    def self.method_missing(sym, *args, &blk)
      case
      when sym.to_s =~ /(.+)=$/ && valid_key?($1.to_sym) then
        @config.send(sym, *args, &blk)
      when @config.respond_to?(sym) then
        @config.send(sym, *args, &blk)
      else
        super
      end
    end

  end

  def self.log_message(level, message, params={})
    ::Ragnar::Config.logger.send(level, message)
  rescue => e
    $stdout << <<-LOG
      No Logger found in ::Ragnar::log_message

      Attempted to Log:
        message : #{message}
        params : #{params}
    LOG
    $stdout << $/
  end
end

Ragnar::Config.restore_defaults!
