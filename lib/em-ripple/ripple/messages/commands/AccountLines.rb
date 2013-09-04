require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Returns information about the specified account's ripple credit lines.
      class AccountLines < Command

        rpc_name 'account_lines'

      end

    end
  end
end
