module Cottontail
  module Model
    def self.included(base)
      base.after_create :notify_created
      base.after_update :notify_updated
      base.after_destroy :notify_destroyed
    end

    def notify_created
      notify_event(:created)
    end

    def notify_updated
      notify_event(:updated)
    end

    def notify_destroyed
      notify_event(:destroyed)
    end

    def notify_event(event)
      # Cottontail.debug "#{self.class.to_s} #{event.to_s.capitalize}!"
      # connection = Bunny.new
      # connection.start
      # channel = connection.create_channel
      # _type = self.class.to_s.downcase
      # key = "#{_type}.#{event.to_s}"
      # exchange = channel.topic("events", auto_delete: false, durable: true)
      # payload = { "#{_type}_id" => self._id }
      # Cottontail.debug "Publishing #{payload} on 'events' keyed to #{key}"
      # exchange.publish(payload.to_json, {persistent: true, routing_key: key})
      # connection.close
    end
  end
end
