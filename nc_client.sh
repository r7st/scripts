#!/bin/sh

<< EOF
client script for nc chat server, such as "ncat -4lvp 9999 --chat".
run script and your messages will be prepended with timestamp.
timestamp will ONLY show for other clients.
type /quit to exit. cleans up ALL nc connections. 
if you quit without /quit (such as ^C), pkill nc to disconnect.
EOF

UNAME=$USER; HN=localhost; PORT=9999; FIFO=tss.fifo
NCCom() { tail -f $FIFO | nc $HN $PORT; }
[ -e $FIFO ] && rm $FIFO
mkfifo $FIFO 
[ $? = 0 ] || { echo "Could not create fifo. exiting..." 1>&2; exit 1; }
NCCom &
echo "User $UNAME has connected at `date +%H:%M`." > $FIFO
while IFS= read -r Line; do
  [ ! -z "$Line" ] && [ "$Line" = "/quit" ] && break
  echo "[$UNAME - `date +%H:%M`]: $Line" > $FIFO
done
echo "User $UNAME has disconnected at `date +%H:%M`." > $FIFO
pkill nc
[ -e $FIFO ] && rm $FIFO
