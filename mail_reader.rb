require 'rubygems'
require 'mail'

# A basic class that retrieves all messages in a mailbox and yields each
# message to a block.  Uses the Mail gem.
class MailReader
  # If a block is given, it is passed to Mail.defaults to alter settings
  # of Mail
  def initialize(&settings)
    Mail.defaults(&settings) if block_given?
  end
end
