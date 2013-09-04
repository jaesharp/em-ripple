require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Retrieves ledger data (see specifiers for selector information)
      class Ledger < Command

        rpc_name 'ledger'

      end

    end
  end
end
