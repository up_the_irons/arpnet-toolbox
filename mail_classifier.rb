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
# the body of a message.  token may be a single token or an array of tokens.
class MailClassifierByToken < MailClassifierBase
  def initialize(msg, tokens)
    super(msg)
    @tokens = [tokens].flatten
  end

  # Return a class within the MailClassification module that matches the
  # alphanumeric part of the token; if no tokens are found or
  # MailClassification class does not exist, nil is returned.  If multiple
  # tokens could have matched, and the corresponding MailClassification class
  # exists, the first match wins.
  def classification
    @tokens.each do |token|
      if @msg.body =~ /#{token}/m
        begin
          t = token.gsub(/[^a-zA-Z0-9]/, '')
          return MailClassification.const_get(t).new(@msg)
        rescue NameError
          nil
        end
      end
    end

    nil
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
