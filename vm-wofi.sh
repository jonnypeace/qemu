#!/bin/bash

# Author: Jonny Peace
# This scripts makes it easy to spin up virtual machines using wofi in dmenumode, and you don't need to use the terminal.
# You can set a keyboard shortcut to run this script which will search the directory it's located
# And provide a list of vm scripts to run.
# I have included a skipfiles text file which lists scripts to excluded.

# comment this if you'd rather list excluded files.
# Also, this is assuming location of files located in $HOME/qemu
skipscript="$HOME"/qemu/skipfiles.txt

# directory for this qemu script project
# This is assuming location of files located in $HOME/qemu
dirscript="$HOME"/qemu

# comment this if you uncomment the scripts variable above above.
scripts=$(find "$dirscript" -type f -name "*.sh" $(printf '! -name %s ' $(< "$skipscript")) | wofi -d)

if [[ "$scripts" ]]; then
    source "$scripts"
    else
    echo "No scripts required" && exit 0
fi
