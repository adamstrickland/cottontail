require "cottontail/version"
require "cottontail/leporine"
require "cottontail/consumable"
require "cottontail/producible"
require "cottontail/consumer"
require "cottontail/producer"
require "cottontail/worker"

module Cottontail
  DEFAULT_TOPIC = "topic"

  class Configuration
    attr_accessor :user, :password, :host, :port, :vhost, :logger, :topic, :verbose
    attr_reader :scheme

    def initialize
      self.user = "guest"
      self.password = "guest"
      self.host = "localhost"
      self.port = 5672
      self.vhost = "%2f"
      @scheme = "amqp"
      self.logger = Logger.new($stdout)
      self.topic = DEFAULT_TOPIC
      self.verbose = false
    end

    def url=(url)
      uri = URI.parse(url)
      self.user = uri.user unless uri.user.nil?
      self.password = uri.password unless uri.password.nil?
      self.host = uri.host
      self.port = uri.port unless uri.port.nil?
      self.vhost = uri.path.gsub(/\//, '') unless uri.path.nil? or uri.path == ""
    end

    def url
      "#{self.scheme}://#{self.user}:#{self.password}@#{self.host}:#{self.port}/#{self.vhost}"
    end
  end

  def self.subscribe(key, *args, &block)
    argc = args.size
    raise ArgumentError, "wrong number of arguments (#{argc+1} for 1..3)" if argc > 2

    if block_given?
      _subscribe_with_block(key, *args, &block)
    else
      _subscribe_with_class(key, *args)
    end
  end

  def self._subscribe_with_class(key, handler, options={})
    raise ArgumentError, "wrong number of arguments (block required OR supplied as 2nd argument)" if handler.nil?
    raise ArgumentError, "invalid options" unless options.kind_of?(Hash)

    consumer = handler.new

    binding.pry unless consumer.respond_to?(:handle_message)

    %i(handle_message handle_payload).each do |m|
      raise ArgumentError, "invalid handler; must implement :#{m}" unless consumer.respond_to?(m)
    end

    ::Cottontail::Worker.new({queue: key, key: key, consumer: consumer}.merge(options)).start!
  end

  def self._subscribe_with_block(key, options={}, &block)
    handler = self.handlerify(&block)
    _subscribe_with_class(key, handler, options)
  end

  def self.configure
    yield(self.configuration) if block_given?
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.publish(payload, key, options={})
    Producer.new.publish(payload, key, options)
  end

  def self.logger
    self.configuration.logger
  end

  def self.verbose?
    self.configuration.verbose
  end

  def self.info(message)
    self.configuration.logger.info(message) if self.verbose?
  end

  def self.debug(message)
    self.configuration.logger.debug(message) if self.verbose?
  end

  def self.warn(message)
    self.configuration.logger.warn(message)
  end

  def self.error(message)
    self.configuration.logger.error(message)
  end

  def self.handlerify(&block)
    raise "A block is required" unless block_given?

    Class.new(Consumer) do
      define_method(:handle_message, &block)
    end
  end
end
