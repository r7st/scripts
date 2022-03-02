#!/usr/bin/env bash
set -eo pipefail

NVAL=10

Warn() {
  # Incomplete
  echo "Usage: cmd -c [-i] [-p] [-n]" 1>&2; exit 1
  echo "Usage: cmd -d [-o]" 1>&2; exit 1
}

GetAlg() {
  case "$1" in 
    bzip2 ) Alg="bzip2 -c"; Ext=tbz2;;
    gzip ) Alg="gzip"; Ext=tgz;;
    xz ) Alg="xz"; Ext=txz;;
    * ) echo Invalid Compression Algorithm..; exit 1
  esac
}

CreateArchive() {
  [ -z $Indir ] && Warn
  [ -z $Outdir ] && Warn
  [ -z $Archname ] && Warn
  Cmd="tar cf - $Indir"; Ext=tar
  if [ ! -z $ALG ]; then
    GetAlg $ALG
    Cmd="$Cmd | $Alg"
  fi
  [ ! -z $Encrypt ] && { Cmd="$Cmd | gpg -c -o-"; Ext="$Ext.gpg"; }
  [ ! -z $Secsize ] && Cmd="$Cmd | split -d -b$Secsize -a 3 - $Outdir/$Archname.$Ext-p"
  [ -z $Secsize ] && Cmd="$Cmd > $Outdir/$Archname.$Ext"
#  echo $Cmd
  eval "nice -n$NVAL $Cmd"
  exit 0
}

ExtractArchive() {
  exit 0
}

Create=0; Extract=0
while getopts ":cdi:o:n:E:S:e" opt; do
  case "${opt}" in
    c ) Create=1;; 
    d ) Extract=1;;
    i ) Indir=$OPTARG;;
    o ) Outdir=$OPTARG;;
    e ) Encrypt=1;;
    n ) Archname=$OPTARG;;
    E ) ALG=$OPTARG;;
    S ) Secsize=$OPTARG;;
    \? ) Warn;;
  esac
done

[ $((Create + Extract)) -eq 1 ] || { echo Must archive or extract; exit 1; }
[ $Create -eq 1 ] && CreateArchive
[ $Extract -eq 1 ] && ExtractArchive
