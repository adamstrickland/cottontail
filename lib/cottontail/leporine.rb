require 'bunny'

module Cottontail
  module Leporine
    attr_accessor :channel, :connection, :exchange

    def initialize(options={})
      @connection = options[:connection] || _create_connection
      @channel = options[:channel] || _create_channel
      @exchange = @channel.topic(options[:exchange] || Cottontail.configuration.topic, { auto_delete: false, durable: true }.merge(options[:exchange_options] || {}))

      @channel.on_error(&method(:handle_channel_exception))
    end

    def handle_channel_exception(channel, channel_close)
      Cottontail.error "Oops... a channel-level exception occurred: code => #{channel_close.reply_code}, message => '#{channel_close.reply_text}'"
    end

    def publish(message, key, options={})
      @exchange.publish(message.to_json, { persistent: true }.merge(options.merge(routing_key: key)))
    end

    def _create_channel
      self.connection.create_channel
    end

    def _create_connection
      _url = Cottontail.configuration.url
      Cottontail.info "Connecting to RabbitMQ at #{_url}"
      connection = Bunny.new(_url)
      connection.start
      connection
    end
  end
end
