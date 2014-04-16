require 'mail_base'

module MailForwarder
  class Base < MailBase
    def initialize(msg, opts = {}, &block)
      super(&block) if block_given?

      @msg = msg
      @opts = {
        :subject_prefix => "FW: "
      }.merge(opts)
    end

    def subject(s = nil)
      s || @opts[:subject_prefix] + @msg.subject
    end

    def send(*args)
      raise NotImplementedError.new("Implement me in a child class")
    end
  end

  module AsAttachment
    class Base < MailForwarder::Base
    end

    # A basic class to forward email (as an attachment).  Uses the Mail gem.
    class Simple < Base
      def send(to, from, body, opts = {})
        subject = subject(opts[:subj])

        mail = Mail.new
        mail[:to] = to
        mail[:from] = from
        mail[:subject] = subject
        mail[:body] = body

        mail.add_part(@msg)
        mail.deliver!
      end
    end
  end
end
