#!/bin/bash

# Author: Jonny Peace
# This scripts makes it easy to spin up virtual machines using dmenu, and you don't need to use the terminal.
# You can set a keyboard shortcut to run this script which will search the directory it's located
# And provide a list of vm scripts to run.
# I have included a skipfiles text file which lists scripts to excluded.

# comment this if you'd rather list excluded files.
skipscript=/home/jonny/qemu-term-vms/skipfiles.txt
# directory for this qemu script project
dirscript=/home/jonny/qemu-term-vms

# uncomment this if you'd rather list excluded scripts.
#scripts=$(find $dirscript -type f -name "*.sh" ! -name "master.sh" ! -name "vm-dmenu.sh" | dmenu -l 20)

# comment this if you uncomment the scripts variable above above.
scripts=$(find $dirscript -type f -name "*.sh" $(printf "! -name %s " $(cat $skipscript)) | dmenu -l 20)

if [ "$scripts" ]; then
    kvmdir=$(awk 'BEGIN{FS=OFS="/"}{NF--; print}' <<< $scripts)
    cd $kvmdir
    kvm=$(awk -F/ '{print $NF}' <<< $scripts)
    /bin/bash $kvm
    else
    echo "No scripts required" && exit 0
fi
