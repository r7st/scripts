#!/usr/local/bin/bash

# crappy wip script to check for vulnerable packages
#curl -s https://vuxml.FreeBSD.org/freebsd/9ca85b7c-1b31-11eb-8762-005056a311d1.html | sed -rn '/<li>CVE-/s/.*: (.*)<\/li>$/\1/p'

echo === host ===
Vulnerable=(`pkg audit -F | sed -rn '/is vulnerable/s/([^ ]+) .*/\1/p'`)
if [ "${#Vulnerable[@]}" = 0 ]; then
  echo No vulnerable packages in host
else
  echo Attempting to update host...
  pkg update
  for Vulnerability in "${Vulnerable[@]}"; do
    echo Attempting to upgrade $Vulnerability in host...
    pkg install $Vulnerability
    echo
  done
fi

echo
jails=(`sed -rn '/\{/s/^([^ #]+) .*/\1/p' < /etc/jail.conf`)
for jail in "${jails[@]}"; do
  echo === jail $jail ===
  Vulnerable=(`pkg -j $jail audit -F | sed -rn '/is vulnerable/s/([^ ]+) .*/\1/p'`)
  if [ "${#Vulnerable[@]}" = 0 ]; then
    echo No vulnerable packages in $jail.
  else
    for Vulnerability in "${Vulnerable[@]}"; do
      echo $Vulnerability is vulnerable.
      ProblemPackages+=($jail,$Vulnerability)
      ProblemJails+=($jail)
    done
  fi
  echo
done

echo
ProblemJails=(`tr ' ' '\n' <<< "${ProblemJails[@]}" | sort -u | tr '\n' ' '`)
for Jail in "${ProblemJails[@]}"; do
  echo Attempting to update $Jail...
  pkg -j $Jail update
done

echo
for Problem in "${ProblemPackages[@]}"; do
  Jail=`cut -f1 -d"," <<< $Problem`
  Package=`cut -f2 -d"," <<< $Problem`
  echo Attempting to upgrade $Package in $Jail...
  pkg -j $Jail install $Package
  echo
done

