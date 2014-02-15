require 'mail_base'

class MailForwarderBase < MailBase
  def initialize(msg, opts = {})
    @msg = msg
    @opts = {
      :subject_prefix => "FW: "
    }.merge(opts)
  end

  def subject(s = nil)
    s || @opts[:subject_prefix] + @msg.subject
  end
end

# A basic class to forward email (as an attachment).  Uses the Mail gem.
class MailForwarderAsAttachment < MailForwarderBase
  def send(to, from, body, subj = nil)
    subject = subject(subj)

    mail = Mail.new
    mail[:to] = to
    mail[:from] = from
    mail[:subject] = subject
    mail[:body] = body

    mail.add_part(@msg)
    mail.deliver!
  end
end
