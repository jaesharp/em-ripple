require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Verifies if data is signed by a given signature
      class DataVerify < Command

        rpc_name 'data_verify'

      end

    end
  end
end
