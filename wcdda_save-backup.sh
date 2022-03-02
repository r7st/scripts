#!/bin/bash

# daily incremental backups, new archive weekly
# use full paths for cron

DataDir=/home    # dir to backup
BackupDir=/saves # dir to store backups
NVal=10          # nice value

Arch=saves-`date +%y%W`-p`date +%u`.tbz2
Snar=saves-`date +%y%W`.snar

# incremental arcive for the week, p1 -> p7
BackupFiles() {
	[ -f $BackupDir/$Arch ] && return
	echo Backing up files for `date`...
	nice -n$NVal tar -g $BackupDir/$Snar -jcf $BackupDir/$Arch -C`dirname $DataDir` $DataDir
}

# tar week's files into single tarball on sunday
TarWeek() {
	SF=$1
	[ -f $BackupDir/backup-$SF.tar ] && return
	Files=(`find $BackupDir -maxdepth 1 -type f -regextype posix-extended -regex ".*-$SF.*"`)
	echo Tarring week `sed -nr 's/[0-9]{2}([0-9]{2})/\1/p' <<< $SF`...
	for File in "${Files[@]}"; do
 	 	nice -n$NVal tar --remove-files -C $BackupDir -rf $BackupDir/backup-$SF.tar `basename $File`
	done
}

# tar all completed weeks (should be just most recent)
TarAll() {
	Full=(`find $BackupDir -maxdepth 1 -type f -regextype posix-extended -regex '.*-p7.tbz2$'`)
	for F in "${Full[@]}"; do
		Week=`sed -rn '/p7/s/.*saves-([0-9]{4})-p7.tbz2$/\1/p' <<< $F`
		TarWeek $Week
	done
}

BackupFiles
TarAll
exit 0 # be happy cron be happy!
