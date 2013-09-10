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

            def self.connect(host, port: DEFALUT_WEBSOCKET_PORT, path: '/')
              client = EventMachine::WebSocketClient.connect(construct_url(host, port, path))
              web_socket_transport = new(client)

              client.connected do
                web_socket_transport.connection_completed
              end

              web_socket_transport
            end

            def initialize webSocketClient
              @client = webSocketClient
            end

            def connection_completed
            end

            def callback
              @client.callback do
                yield
              end
            end

            def send_msg(message)
              @client.send_msg(message)
            end

            def disconnect
              @client.disconnect do
                yield
              end
            end

            def stream &proc
              @client.stream do |msg|
                yield msg
              end
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