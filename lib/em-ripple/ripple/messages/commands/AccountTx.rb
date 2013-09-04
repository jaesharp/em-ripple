require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Fetch a list of transactions that applied to the specified account.
      class AccountTx < Command

        rpc_name 'account_tx'

      end

    end
  end
end
