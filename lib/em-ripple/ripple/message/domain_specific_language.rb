require 'em-ripple/ripple/message/field'

module EMRipple
  module Ripple
    module Message

      module DomainSpecificLanguage

        module ClassMethods

          @fields = []

          attr_reader :fields

          def field name, options = {}
            @fields << Field.new(name, options)
          end

          @rpc_name = nil

          def rpc_name name
            @rpc_name = name
          end

          attr_reader :rpc_name

          @repsonse = nil


        end

      end

    end
  end
end