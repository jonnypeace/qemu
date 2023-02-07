#!/bin/bash

function backup {

  mkdir -p "$dirto"

  # incremental file which keeps track of changes (no need to change this)
  incfile=file.inc

  # date for directory and .tgz file naming
  day=$(date +'%F')

  #Check number of directories with week-ending, and count them
  dirnum=$(find "$dirto" -name "*week-ending*" -type d | wc -l)

  # My aim is to keep two weeks of backups at all times.
  # If you want to adjust this, adjust the number 3 accordingly.
  # Example: 3 will keep 2 full weeks of dailing backups.
  if [[ "$dirnum" -ge 3 ]]; then
    dir1=$(find "$dirto" -name "*week-ending*" | sort | awk 'NR==1{print}')
    rm -r "$dir1";
  fi

  # Counting the number .tgz files
  filenum=$(find "$dirto" -name "*.tgz" -type f | wc -l)

  # Once 7 .tgz are created, move them to a new week-ending directory
  # If run daily on cron job, this will be a weeks worth of incremental backups
  if [[ "$filenum" -ge 7 ]]; then
    mkdir -p "$dirto"/week-ending-"$day"
    mv "$dirto"/*.tgz "$dirto"/week-ending-"$day"
    mv "$dirto"/"$incfile" "$dirto"/week-ending-"$day"
  fi

  # Create .tgz file. Ideally this will work in a cron job, and you'll get daily backups
  # to exclude a directory after the tar command, example --exclude='/home/user/folder'
  tar -vcz -g "$dirto"/"$incfile" -f "$dirto"/"$backfile"-"$day".tgz "$dirfrom"
}

function recovery {

  mkdir -p "$dirto"

  for file in "$dirbk"/*.tgz ; do
    tar -x -g /dev/null -f "$file" -C "$dirto"
  done

}

while getopts b:r:d:f:h opt
do
  case "$opt" in
    
    b) 
      dirfrom="$OPTARG"
      backup ;;
    r)
      dirbk="$OPTARG"  
      recovery ;;
    d)
      dirto="$OPTARG" ;;
    f)
      backfile="$OPTARG" ;;
    h)
    cat << EOF

    backup.sh script for backup and recovery.

    Select -b for backup followed by backup directory
    Select -r for recovery followed by location of backup directory
    Select -d for destination followed by directory to restore or backup to
    Select -f for name of backup file
    Select -h for this help

  * Example for backup (IMPORTANT: the -b flag comes at end of command):

      ./backup.sh -d /mnt/NFS/backup/fedora/ -f fedora -b $HOME/qemu/fedora/

  * Example for restore (IMPORTANT: the -r flag comes at end of command):

      ./backup.sh -d $HOME/qemu/fedora/ -r /mnt/NFS/backup/fedora/

EOF
    exit ;;
    *)
      echo 'Incorrect option selected, run ./backup.sh -h for help' 
      exit
  esac
done
