require 'em-ripple/ripple/client/peer/transport'
require 'em-websocket-client'

module EMRipple
  module Ripple
    class Client
      class Peer
        module Transports

          class WebSocket < Transport

            DEFAULT_WEBSOCKET_PORT = 80 # most WebSockets are protocol upgraded from HTTP

            attr_reader :client

            def self.connect(host, port: DEFALUT_WEBSOCKET_PORT, path: '/', client: nil)
              client ||= EventMachine::WebSocketClient.connect(construct_url(host, port, path))

              web_socket_transport = new(client)

              client.connected do
                web_socket_transport.connection_completed
              end

              client.callback do
                web_socket_transport.handshake_completed
              end

              client.stream do |message|
                web_socket_transport.raw_response_received(message)
              end

              client.disconnect do
                disconnected
              end

              web_socket_transport
            end

            def initialize(webSocketClient)
              super
              @client = webSocketClient
            end

            def send_raw(message)
              @client.send_msg(message)
            end

            private

            def self.construct_url(host, port, path = '/')
              "ws://#{host}:#{port}#{path}"
            end

          end

        end
      end
    end
  end
end