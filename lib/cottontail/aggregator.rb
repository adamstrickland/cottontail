require "cottontail/worker"

module Cottontail
  class Aggregator < Worker
    attr_accessor :map

    def initialize(options={})
      super(options)
      @map = {}
      @subscription_options = { ack: true, block: false }
    end

    def on_message(delivery_info, metadata, payload)
      self.map[metadata[:correlation_id]] = (self.map[metadata[:correlation_id]] || []) + [payload]
      Cottontail.debug "#{metadata[:headers]['correlation_count'].to_i} / #{self.map[metadata[:correlation_id]].size} messages for #{metadata[:correlation_id]} found"
      if self.map[metadata[:correlation_id]].size == metadata[:headers]['correlation_count'].to_i
        self.consumer.handle_message(delivery_info, metadata, payload)
        self.map.delete(metadata[:correlation_id])
      end
    end
  end
end
