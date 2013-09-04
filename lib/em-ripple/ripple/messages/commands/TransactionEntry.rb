require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Requests a completed transaction from the network
      class TransactionEntry < Command

        rpc_name 'transaction_entry'

      end

    end
  end
end
