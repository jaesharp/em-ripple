require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Submits a transaction to the network
      class Submit < Command

        rpc_name 'submit'

      end
    end
  end
end
