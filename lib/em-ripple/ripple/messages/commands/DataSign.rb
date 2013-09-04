require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Signs data with the private key of an address
      class DataSign < Command

        rpc_name 'data_sign'

      end

    end
  end
end
