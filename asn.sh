#!/bin/sh
#
# Query CIDR REPORT for ASN info
#
# Created: 03-12-2009

CACHE_DIR=~/.cache/ASNs

usage() {
  echo "$0 <ASN> [force-update]"
  echo ""
  echo "  <ASN>            ASN to query"
  echo "  [force-update]   any non-empty string, forces cache refresh"
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

# Sanitize the input, stripping any "AS" off the front of the string
ASN=${1##AS}

if [ ! -d $CACHE_DIR ]; then
  mkdir -p $CACHE_DIR
fi

AS_FILE="$CACHE_DIR/AS$ASN.txt"

if [ -n "$2" ]; then
  rm $AS_FILE
fi

if [ ! -f $AS_FILE ]; then
  lynx -dump "http://www.cidr-report.org/cgi-bin/as-report?as=AS$ASN&v=4&view=2.0" > $AS_FILE
fi

less -F $AS_FILE
