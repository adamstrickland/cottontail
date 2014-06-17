module Cottontail
  module Consumable
    def handle_message(delivery_info, metadata, payload)
      # Cottontail.debug "HANDLING MESSAGE of type #{metadata.content_type}"
      handle_payload(payload)
    end

    def handle_payload(payload)
      Cottontail.debug "HANDLING PAYLOAD #{payload}"
    end
  end
end
