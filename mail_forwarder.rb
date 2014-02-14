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
