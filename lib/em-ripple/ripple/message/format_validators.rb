module EMRipple
  class Message

    # A Collection of Format Validators. Ripple communications messages in various formats
    # (protobufs, json-rpc, and json over websocket)
    module FormatValidators
    end

  end
end

require 'em-ripple/ripple/message/format_validators/json_format_validator'
