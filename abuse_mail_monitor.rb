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

# TODO: :delete_after_find => true, after testing
monitor = MailMonitor.new(60, { :delete_after_find => false }, &CONFIG[:mail])
monitor.go do |msg|
  begin
    # @to = TODO Lookup to whom to forward
    @ip = IpFinder.new.find(msg.body.to_s) ||
          IpFinder.new.find(msg.subject, 'server used for an attack: ')
    # @account = IpBlock.account(@ip)

    mail_class = classifier.classification(msg)

    if mail_class
      forwarder = mail_class.forwarder.new(msg)
      # forwarder.send(@to, from, body)
      puts "NOTICE: Sent to #{@to} message with subject: '#{msg.subject}'"
    else
      puts "NOTICE: Could not classify message: #{msg.subject}"
    end
  rescue Exception => e
    $stderr.puts e
  end
end

# TODO: WIP
# def notify!(error)
#   mail = Mail.new do
#     to ARPNET_EXCEPTION
#   end
# end

# TODO: WIP
# AbuseMailMonitor? to be something like above &^^^^^
#   will have to() method that is abstract
