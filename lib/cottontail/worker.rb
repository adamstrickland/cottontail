require "cottontail/leporine"
require "cottontail/consumer"

module Cottontail
  class Worker
    include Cottontail::Leporine

    attr_accessor :name, :queue, :queue_options, :keys, :consumer

    def initialize(options={})
      super(options)

      @consumer = options[:consumer] || Cottontail::Consumer.new
      @keys = if options.keys.include?(:key)
                [options[:key]]
              elsif options.keys.include?(:keys)
                options[:keys]
              else
                raise "Options must include either :key => String or :keys => [String, ...]"
              end
      @name = options[:queue] || _random_queue_name
      @queue_options = options[:queue_options] || { auto_delete: false, durable: true }
      Cottontail.debug "Worker configured to use consumer #{@consumer} listening on #{@queue} with options #{@queue_options} for keys #{@keys.join(',')}"
    end

    def start!
      @queue = @channel.queue(self.name, self.queue_options)
      Cottontail.debug "Worker listening on queue #{@queue}"

      _decorate_consumer(@consumer)

      self.keys.each do |key|
        @queue.bind(@exchange, routing_key: key).subscribe(&@consumer.method(:handle_message))
        Cottontail.debug "Bound consumer #{@consumer} to routing key #{key}"
      end
    end

    private

    def _decorate_consumer(consumer)
      consumer.define_singleton_method :publish, &self.method(:publish)
      consumer.define_singleton_method :notify do |event, payload, options={}|
        publish(payload, event, options)
      end
    end

    def _random_queue_name
      "cottontail-worker.#{SecureRandom.hex}"
    end
  end
end
