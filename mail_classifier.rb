# Base class for a mail classification system.  Uses the Mail gem.
#
# Input is a Mail object.  Output will indicate what category or class the
# mail is considered to be.  Examples include:
#
#   - SPAM
#   - DMCA Takedown Notice
#   - DDoS Abuse Report
#   - Open SMTP Relay Notice
#
class MailClassifierBase
  def initialize(msg)
    @msg = msg
  end
end

# The simplest kind of classification.  Looks for a specific token within
# the subject or body of a message.
class MailClassifierByToken < MailClassifierBase
  def initialize(msg, token)
    super(msg)
    @token = token
  end
end
