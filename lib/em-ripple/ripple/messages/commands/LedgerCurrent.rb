require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Returns the current proposed ledger index.
      class LedgerCurrent < Command

        rpc_name 'ledger_closed'

      end

    end
  end
end
