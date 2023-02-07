#!/bin/bash

function backup {

  mkdir -p "$dirto"

  # date for directory and .tgz file naming
  day=$(date +'%F')

  # Counting the number .tgz files
  filenum=$(find "$dirto" -name "*.tgz" -type f | wc -l)

  # Create .tgz file
  tar -vcz -f "$dirto"/"$backfile"-"$day".tgz "$dirfrom"
}

function recovery {

  mkdir -p "$dirto"
  mapfile -t array < <(find "$dirbk" -type f -name "*.tgz")
  echo
  for i in "${!array[@]}"; do
    cat << EOF
    $i) ${array[i]}
EOF
  done
  echo
  read -rp 'Enter number associated with backup file for recovery: ' ans

  tar -vxf "${array[ans]}" -C "$dirto"

}

while getopts b:r:d:f:h opt
do
  case "$opt" in
    
    b) 
      dirfrom="$OPTARG"
      if [[ "${dirfrom:0-1}" == '/' ]] ; then dirfrom="${dirfrom::-1}"; fi
      backup ;;
    r)
      dirbk="$OPTARG"  
      if [[ "${dirbk:0-1}" == '/' ]] ; then dirbk="${dirbk::-1}"; fi
      recovery ;;
    d)
      dirto="$OPTARG"
      if [[ "${dirto:0-1}" == '/' ]] ; then dirto="${dirto::-1}"; fi;;
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
