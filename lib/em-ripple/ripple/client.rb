require 'em-ripple/ripple/client/peer'

module EMRipple
  module Ripple

    class Client

      DEFAULT_PORT = 443
      DEFAULT_TRANSPORT = EMRipple::Ripple::Client::Peer::Transports::SecureWebSocket

      def self.connect(host, port: DEFAULT_PORT, dry_run: false, transport: DEFAULT_TRANSPORT)
        client = new(dry_run)

        client.add_peer!(host: host, port: port)
      end

      def initialize(dry_run: false)
        @peers = []
        @dry_run = dry_run
      end

      def add_peer!(host, port: DEFAULT_PORT, transport: DEFAULT_TRANSPORT)

        new_peer = Peer.new(host, port: port, transport: transport)

        if dry_run
          new_peer.disable_transaction_creation!
        end

        @peers << new_peer

      end

    end

  end
end