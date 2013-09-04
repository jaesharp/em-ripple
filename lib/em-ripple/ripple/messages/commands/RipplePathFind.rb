require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Find a path and estimated costs. Expensive command, use PathFind in its place if possible.
      class RipplePathFind < Command

        rpc_name 'ripple_path_find'

      end

    end
  end
end
