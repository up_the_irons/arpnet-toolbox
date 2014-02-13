require 'rubygems'
require 'mail'

# A basic class that retrieves all messages in a mailbox and yields each
# message to a block.  Uses the Mail gem.
class MailReader
  # If a block is given, it is passed to Mail.defaults to alter settings
  # of Mail.  Unless you set Mail.defaults elsewhere, you're going to want
  # to do it here.
  #
  # === Example for IMAP and Gmail:
  #
  #   MailReader.new do
  #     retriever_method :imap, { :address             => "imap.googlemail.com",
  #                               :port                => 993,
  #                               :user_name           => '<username>',
  #                               :password            => '<password>',
  #                               :enable_ssl          => true }
  #   end
  def initialize(&settings)
    Mail.defaults(&settings) if block_given?
  end
end
