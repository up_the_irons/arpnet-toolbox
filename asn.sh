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

# Sanitize the input, stripping any "AS" or "as" off the front of the string
# TWO stores the first two characters of the input sting
# SIZE stores the length of the input string

TWO=$(echo "$1" | cut -b 1,2)
SIZE=${#1}

if [ "$TWO" = "AS" ] || [ "$TWO" = "as" ] ; then
  ASN=$(echo "$1" | cut -b 3-$SIZE)
else
  ASN=${1##AS}
fi

# Ensure that once the leading "AS" or "as" has been removed, no letters still exist
# NUM stores the numeric portion of the input string, after AS and as have been removed
NUM=$(echo "$1" | sed "s/[^0-9]*//g")

if [ "$ASN" != "$NUM" ]; then
  usage
  exit 1
fi


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
