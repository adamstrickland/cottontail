require "cottontail/version"
require "cottontail/leporine"
require "cottontail/consumable"
require "cottontail/producible"
require "cottontail/consumer"
require "cottontail/producer"
require "cottontail/worker"

module Cottontail
  class Configuration
    attr_accessor :user, :password, :host, :port, :vhost
    attr_reader :scheme

    def initialize
      self.user = "guest"
      self.password = "guest"
      self.host = "localhost"
      self.port = 5672
      self.vhost = "%2f"
      @scheme = "amqp"
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

  def self.configure
    yield(self.configuration) if block_given?
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.publish(payload, key, options={})
    Producer.new.publish(payload, key, options)
  end
end
