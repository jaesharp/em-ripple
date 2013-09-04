module EMRipple
  module Ripple
    module Message

      class Field

        def initialize(name, options = Hash.new)
          @name = name
          @options = options
          @value = nil
        end

        attr_reader :name
        attr_accessor :value

        def valid?
          # TODO: Integrate with validators
          true
        end

      end

    end
  end
end