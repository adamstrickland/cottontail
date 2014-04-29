module Cottontail
  module Consumable
    def handle_message(delivery_info, metadata, payload)
      puts "HANDLING MESSAGE #{payload} of type #{metadata.content_type}"
    end

    def notify(event, payload)
    end
  end
end
