require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Stop receiving selected streams from the server.
      class Unsubscribe < Command

        rpc_name 'unsubscribe'

      end

    end
  end
end
