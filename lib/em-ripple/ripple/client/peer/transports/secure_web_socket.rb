require 'em-ripple/ripple/client/peer/transports/web_socket'

module EMRipple
  module Ripple
    class Client
      class Peer
        module Transports

          class SecureWebSocket < WebSocket

            def connection_completed
              client.start_tls
            end

          end

        end
      end
    end
  end
end