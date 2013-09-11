module EMRipple
  module Ripple
    class Client
      class Peer

        class Transport

          class NullSerialiser

            def self.serialise(command, id)
              command
            end

          end

          class NullDeserialiser

            def self.deserialise(response)
              response
            end

          end

          def initialize(client)
            @handshake_completed_callbacks = []
            @response_received_callbacks = []
            @disconnected_callbacks = []

            @active_subscriptions = []
            @outstanding_commands = []
          end

          def send_command(command)
            register_outstanding_command(command)
            serialised_command = serialise_command(command)
            send_raw(serialised_command)
          end

          def on_handshake_completed(&callback)
            @handshake_completed_callbacks << callback
          end

          # When the transport receives a message the provided procedure is called and is
          # passed the command object for which the response was generated, as well as the response message object.
          def on_response_received(&callback)
            @response_received_callbacks << callback
          end

          def on_disconnect(&callback)
            @disconnected_callbacks << callback
          end

          def handshake_completed
            @handshake_completed_callbacks.each do |callback|
              callback.yield
            end
          end

          def disconnected
            @disconnected_callbacks.each do |callback|
              callback.yield
            end
          end

          def raw_response_received(serialised_response)
            response = deserialise_response(serialised_response)
            #issuing_command = retrieve_issuing_command(response)
            issuing_command = nil

            @response_received_callbacks.each do |callback|
              callback.yield(issuing_command, response)
            end

            command_has_been_satisfied(issuing_command, response)
          end

          def register_outstanding_command(command)
            @outstanding_commands << command
          end

          def command_has_been_satisfied(issuing_command, response)
            @outstanding_commands.delete(issuing_command)
          end

          def serialiser
            NullSerialiser
          end

          def serialise_command(command)
            serialiser.serialise(command, id: generated_id)
          end

          def generated_id
            1
          end

          def deserialiser
            NullDeserialiser
          end

          def deserialise_response(response)
            deserialiser.deserialise(response)
          end

          def retrieve_issuing_command(response)
            issuing_command = response.find_issuing_command_in_set(@outstanding_requests + @active_subscriptions)
          end

        end

      end
    end
  end
end
