require 'mail_forwarder'

# A mail classification system.  Uses the Mail gem.
#
# Given a Mail object, we want to indicate the category / class the mail is
# considered to be.  Examles include:
#
#   - SPAM
#   - DMCA Takedown Notice
#   - DDoS Abuse Report
#   - Open SMTP Relay Notice

module MailClassifier
  class Base
    def classification(*args)
      raise NotImplementedError
    end
  end

  # The simplest kind of classification.  Looks for a specific token within
  # the body of a message.  token may be a single token or an array of tokens.
  class ByToken < Base
    def initialize(tokens)
      @tokens = [tokens].flatten
    end

    # Return a class within the Classification module that matches the
    # alphanumeric part of the token; if no tokens are found or Classification
    # class does not exist, nil is returned.  If multiple tokens could have
    # matched, and the corresponding Classification class exists, the first
    # match wins; therefore, tokens should be passed in order of highest to
    # lowest preference
    def classification(msg)
      @tokens.each do |token|
        if msg.body =~ /#{token}/m
          begin
            t = token.gsub(/[^a-zA-Z0-9]/, '')
            return Classification.const_get(t).new(msg)
          rescue NameError
            nil
          end
        end
      end

      nil
    end
  end

  class ByString < Base
    def initialize(strings, klass)
      @klass = klass
      @strings = [strings].flatten
    end

    # Return a class within the Classification module that matches klass
    # (passed in the constructor) if one of the strings (also passed in
    # constructor) is present in msg (body or subject)
    def classification(msg)
      @strings.each do |string|
        if msg.subject =~ /#{string}/m || msg.body =~ /#{string}/m
          begin
            klass = @klass.split("::").inject(Classification) do |sum, x|
              sum.const_get(x)
            end

            return klass.new(msg)
          rescue NameError
            nil
          end
        end
      end

      nil
    end
  end

  # A meta classifier
  class ByClassifier < Base
    def initialize(classifiers)
      @classifiers = classifiers
    end

    # Returns a classification as determined by the classifiers passed during
    # initialization.  If multiple classifiers would have returned a valid
    # class, the first one wins; therefore, classifiers should be passed in
    # order of highest to lowest preference
    def classification(msg)
      @classifiers.each do |classifier|
        if klass = classifier.classification(msg)
          return klass
        end
      end

      nil
    end
  end

  module Classification
    class Base
      def initialize(msg)
        @msg = msg
      end

      def forwarder
        MailForwarder::AsAttachment::Simple
      end
    end

    class SPAM < Base
    end

    class DMCATakedown < Base
    end

    class SMTPOpenRelayNotice < Base
    end

    module Attacks
      # Generic DDoS that doesn't fall into more appropriate category below
      class DDoS < Base
      end

      class NTPAmplification < Base
      end

      class ChargenAmplification < Base
      end

      class SMTPAmplification < Base
      end
    end
  end
end
