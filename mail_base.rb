require 'rubygems'
require 'mail'

class MailBase
  # If a block is given, it is passed to Mail.defaults to alter settings
  # of Mail.  Unless you set Mail.defaults elsewhere, you're going to want
  # to do it here.
  #
  # === Example for IMAP and Gmail:
  #
  #   MailForwarder.new do
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
