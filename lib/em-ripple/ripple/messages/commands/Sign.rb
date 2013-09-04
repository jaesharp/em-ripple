require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Signs a transaction
      class Sign < Command

        rpc_name 'sign'

      end

    end
  end
end
