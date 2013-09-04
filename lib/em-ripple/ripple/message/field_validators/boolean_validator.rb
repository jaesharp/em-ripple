require 'em-ripple/ripple/message/field_validator'

module EMRipple
  module Ripple
    module Message
      module FieldValidators

        class BooleanValidator < FieldValidator

          def self.valid? field
            [true, false].include?(field)
          end

        end

      end
    end
  end
end