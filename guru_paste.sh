#!/usr/bin/env bash
test -f $1 || exit 1
Ext=`sed -rn 's/.*(\.[^.]+$)/\1/p' <<< $1`
Name=`openssl rand -hex 4`$Ext
Serv=r7st.guru ; User=public ; Port=6900 
PPath=/usr/home/$User/public/pastes
SSop="-oPort=$Port -oConnectTimeout=5"
Cto() { [ $1 -eq 0 ] || { echo connection timeout ; exit 1 ; } }
scp $SSop $1 $User@$Serv:$PPath/$Name >/dev/null 2>&1
Cto $?
echo https://$Serv/pastes/$Name
test -z "$2" && exit 0
ssh $SSop -t $User@$Serv << EOF >/dev/null 2>&1
at now + "$2" << EOF1
rm $PPath/$Name
EOF1
exit
EOF
Cto $?
true
