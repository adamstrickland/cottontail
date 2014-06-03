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

  def self.subscribe(key, handler, options = {})
    ::Cottontail::Worker.new({key: key, consumer: handler.new}.merge(options)).start!
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
end
