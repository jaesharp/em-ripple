require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # This is a long-running command which has subcommands.
      # A connection may have open only one active pathfinding request.
      class PathFind < Command

        rpc_name 'path_find'

      end

    end
  end
end
