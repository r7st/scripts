!/usr/bin/env bash

LOGFILE=/var/log/tinyproxy.log
LINES=1000
[ ! -z $1 ] && LINES=$1

#cat $LOGFILE | \
tail -$LINES $LOGFILE | \
  sed -nr '/.*(Connect|Request|Unauthorized).*/p' | \
  awk '
{
  if ($0 !~ /.*Unauthorized.*/) {
     print Prev
  }
  if ($0 ~ /.*(Connect|Request).*/) {
    Prev=$0
  }
}
' | \
egrep "^CONNECT" | \
awk '
{
  if (match($0,/\[[[0-9.]+\]$/)) {
    IP=substr($0, RSTART, RLENGTH)
  }
  #else if (match($0, /: (CONNECT|GET|POST) .*/)) {
  else if (match($0, /: (CONNECT|GET|POST).*:[0-9]/)) {
    Dest=substr($0, RSTART+2, RLENGTH)
    match($0,/[A-Z][a-z]+ [0-9]+ [0-9:]+/)
    Time=substr($0, RSTART, RLENGTH)
    print Time ": " IP " -> " Dest
  }
}
'
