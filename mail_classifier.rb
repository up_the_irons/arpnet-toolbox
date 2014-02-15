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
# the body of a message.
class MailClassifierByToken < MailClassifierBase
  def initialize(msg, token)
    super(msg)
    @token = token
  end

  # Return a class within the MailClassification module that matches the
  # alphanumeric part of the token
  def classification
    begin
      if @msg.body =~ /#{@token}/m
        t = @token.gsub(/[^a-zA-Z0-9]/, '')
        MailClassification.const_get(t).new(@msg)
      end
    rescue NameError
      nil
    end
  end
end

module MailClassification
  class Base
    def initialize(msg)
      @msg = msg
    end
  end

  class SPAM < Base
  end

  class DMCATakedown < Base
  end

  class SMTPOpenRelayNotice < Base
  end
end
