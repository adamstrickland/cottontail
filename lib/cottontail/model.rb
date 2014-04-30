require 'verbs'

module Cottontail
  module Model
    def self.included(base)
      base.send(:extend, Macros)
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

    def identifier
      self.object_id.to_s
    end

    def key_base
      self.class.to_s.downcase
    end

    def notify_event(event)
      Cottontail.debug "#{self.class.to_s} #{event.to_s.capitalize}!"
      key = "#{self.key_base}.#{event.to_s}"
      payload = { identifier: self.identifier }
      Cottontail.debug "Publishing #{payload} on 'events' keyed to #{key}"
      Cottontail.publish(payload, key)
    end

    module Macros
      def notify_on_all
        notify_on :after_create, :after_update, :after_destroy
      end

      def notify_on(*events)
        options = { tense: :past, aspect: :perfective, person: :third }
        callbacks = events.map do |e| 
          occurrence = e.to_s.gsub(/after_/, '').verb.conjugate(options)
          "notify_#{occurrence}".to_sym
        end
        notify_using Hash[*events.zip(callbacks).flatten]
      end

      def notify_using(map)
        map.each do |event, callback|
          self.send(event, callback)
        end
      end
    end
  end
end
