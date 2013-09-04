require 'em-ripple/ripple/messages/command'

module EMRipple
  module Messages
    module Commands

      # Returns the last N transactions starting from provided start index ordered by ledger sequence number descending.
      # Server sets N.
      class TxHistory < Command
      end
    end
  end
end
