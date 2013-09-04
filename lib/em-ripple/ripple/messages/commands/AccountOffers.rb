require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Returns the specified account's outstanding offers.
      class AccountOffers < Command

        rpc_name 'account_offers'

      end

    end
  end
end
