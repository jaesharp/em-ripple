require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Returns the most recently closed ledger index
      class LedgerClosed < Command

        rpc_name 'ledger_closed'

      end

    end
  end
end
