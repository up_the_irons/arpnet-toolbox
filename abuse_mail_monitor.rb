# Abuse Mail Monitor
#
# Copyright ⓒ 2014 ARP Networks, Inc.
#
# :Author: Garry Dolley
# :Created: 02-16-2014
#
# When we receive complaints of abuse (e.g. SPAM, DoS attack, etc...) and that
# abuse can be identified as originating from a particular IP address, we
# forward the complaint to a special email address monitored by this script.
# This monitor can then lookup the customer / owner of the IP and forward the
# complaint.

require 'mail_monitor'
require 'mail_classifier'
require 'ip_finder'

# Site specific, see config.rb.sample
require 'config'

classifier = MailClassifier::ByClassifier.new(CONFIG[:classifiers])
from       = CONFIG[:from]
body       = CONFIG[:body]
headers    = CONFIG[:headers]

puts "NOTICE: Starting monitor..."

monitor = MailMonitor.new(60, { :delete_after_find => true }, &CONFIG[:mail])
monitor.go do |msg|
  begin
    @ip = IpFinder.new.find(msg.body.to_s) ||
          IpFinder.new.find(msg.subject, 'server used for an attack:') ||
          IpFinder.new.find(msg.subject, 'service used for an attack:')

    @to = CONFIG[:to].call(@ip)

    mail_class = classifier.classification(msg)

    # The email that we forward to this processor will be contain two parts:
    #
    #   part 1: the header/body of our email
    #           either empty or containing a tag to identify originating IP
    #   part 2: the original email (abuse complaint)
    #
    # What we want to do is only forward the 2nd part, because it is what is
    # useful.
    orig_email = msg.parts.last

    if mail_class
      forwarder = mail_class.forwarder.new(orig_email)
      forwarder.send(@to, from, body,
                     :subj => "FW: #{msg.subject}",
                     :headers => headers)

      puts "NOTICE: Classified message as #{mail_class.class}"
      puts "NOTICE: Sent to #{@to} message with subject: #{msg.subject}"
    else
      notice = "Could not classify message: #{msg.subject}"
      puts "NOTICE: " + notice

      if to_on_error = CONFIG[:to_on_error]
        # Do we have the original email we can just attach?
        if orig_email
          forwarder = MailForwarder::AsAttachment::Simple.new(orig_email)
          forwarder.send(to_on_error, from, notice,
                         :subj => "FW: #{msg.subject}")
        else
          mail = Mail.new
          mail[:to]   = to_on_error
          mail[:from] = from
          mail[:subject] = notice
          mail.deliver!
        end
      end
    end
  rescue Exception => e
    $stderr.puts e
  end
end
