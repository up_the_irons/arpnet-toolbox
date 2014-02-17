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
require 'arpnet_mail_config' # Site specific

monitor = MailMonitor.new(60, &ARPNET_MAIL_CONFIG)
