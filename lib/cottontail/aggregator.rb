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
      self.map[meta[:correlation_id]] = (self.map[meta[:correlation_id]] || []) + [pyld]
      Cottontail.debug "#{meta[:headers]['correlation_count'].to_i} / #{self.map[meta[:correlation_id]].size} messages for #{meta[:correlation_id]} found"
      if self.map[meta[:correlation_id]].size == meta[:headers]['correlation_count'].to_i
        self.consumer.handle_message(di, meta, pyld)
        self.map.delete(meta[:correlation_id])
      end
    end
  end
end
