require 'em-ripple/ripple/client/peer/transports'

module EMRipple
  class Client

    # A Peer within the Ripple payment network
    class Peer

      def initialize(host, port, transport)
        @can_create_transactions = true
      end

      def disable_transaction_creation!
        @can_create_transactions = false
      end

      def enable_transaction_creation!
        @can_create_transactions = true
      end

    end

  end
end
