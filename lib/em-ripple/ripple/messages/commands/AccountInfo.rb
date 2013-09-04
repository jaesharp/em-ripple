require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Fetches information about the specified account.
      class AccountInfo < Command

        rpc_name 'account_info'

        field :identifier

        # if true, accepts only public ids for account
        field :strict, validator: BooleanValidator, default: false

        field :index, validator: [Integer]
        field :ledger_hash
        field :ledger_index

      end

    end
  end
end
