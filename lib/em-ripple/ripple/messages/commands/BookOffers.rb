require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Returns the offers for an order book
      class BookOffers < Command

        rpc_name 'book_offers'

      end

    end
  end
end
