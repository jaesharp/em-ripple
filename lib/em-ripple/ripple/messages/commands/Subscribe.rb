require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Request selected streams from the ripple server
      class Subscribe < Command

        rpc_name 'subscribe'

      end

    end
  end
end
