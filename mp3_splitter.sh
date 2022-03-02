#!/bin/bash

# pulls audio from youtube vid, converts to mp3, splits to 20 min segments
# first arg is youtube url to vid, second is output file name WITH NO EXTENSION

URL=$1
DEST=$2
[ -z $URL ] && exit 1
[ -z $DEST ] && exit 1

DLComm="youtube-dl -x --audio-format mp3 $URL -o $DEST.%(ext)s"
DLFile="$DEST.mp3"

Split() {
  EncT=(`2>&1 ffmpeg -i "$DLFile" -vn -acodec copy -ss "$1" -t 00:20:00 "$2"`)
  if grep "nothing was encoded" <<< "${EncT[*]}" >/dev/null 2>&1; then
    rm $Fout
    rm $DLFile
    exit 0
  fi
}

MIndex=( 0 20 40 )
Extract() {
  HR=0
  for (( i=0; i < 50; i++ )); do
    MIN=$(( i % 3 ))
    StartTime=`printf "%02d:%02d:00" "$HR" "${MIndex[MIN]}"`
    [ $MIN -eq $(( "${#MIndex[@]}" - 1 )) ] && HR=$(( $HR + 1 ))
    OutInd=`printf "%02d" $i`
    Fout=`sed 's/\.mp3$//' <<< $DLFile`"-$OutInd.mp3"
    echo Extracting $Fout from $DLFile at mark $StartTime...
    Split "$StartTime" "$Fout"
  done
}

echo Downloading and converting $DLFile...
$DLComm
echo Extracting audio from $DLFile...
Extract
