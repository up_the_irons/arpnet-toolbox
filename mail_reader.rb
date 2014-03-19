require 'mail_base'

# A basic class that retrieves all messages in a mailbox and yields each
# message to a block.  Uses the Mail gem.
class MailReader < MailBase
  # Retrieve all messages from the mailbox and yield each to a block.
  # Warning: this can be slow on large mailboxes
  def go
    Mail.all do |msg|
      yield msg
    end
  end
end
