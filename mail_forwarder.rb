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
      s || @opts[:subject_prefix] + @msg.subject.to_s
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
        mail['Content-Disposition'] = 'inline'

        if h = opts[:headers]
          h.each do |k, v|
            mail[k] = v
          end
        end

        @msg.header['Content-Disposition'] = 'inline'
        mail.add_part(@msg)

        # Mail sets Content-Type to 'multipart/alternative' the moment we use
        # add_part() above, yet we want it to be 'multipart/mixed'; not sure
        # why we have to jump through hoops for that
        mail.content_type = nil
        mail.send(:add_multipart_mixed_header)

        mail.deliver!
      end
    end
  end
end
