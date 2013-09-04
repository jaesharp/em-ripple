require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Command used to check connectivity to server. Server will always send a response. Also, useful
      # for ensuring the underlying transport connection is kept alive.
      class Ping < Command

        rpc_name 'ping'

      end

    end
  end
end
