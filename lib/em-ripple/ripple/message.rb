require 'em-ripple/ripple/message/domain_specific_language'

module EMRipple
  module Ripple

    # A Message to be passed from one peer to another
    class Message
      include Message::DomainSpecificLanguage
      extend Message::DomainSpecificLanguage::ClassMethods

      def valid?
        fields.all? do |field|
          field.valid?
        end
      end

    end

  end
end
