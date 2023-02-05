#!/bin/bash

# Author: Jonny Peace
# check cpu threads and select the number required for a vm
function cpu {
	threads=$(grep -i processor /proc/cpuinfo | awk 'END{print $3+1}')
	echo
	echo "You have $threads CPU threads available for your VM"
	echo
	read -rp "Number of CPU threads for VM: " cpu
}

# check available memory, and select the required ram for the vm
function memory {
	echo
	free -m
	read -rp "Memory for VM, i.e. 4G: " memory
}

# check audio devices and select the appropriate device
function audio {
	echo
	qemu-system-x86_64 -device help | grep hda
	echo
	read -rp "Select audio output device, i.e. intel-hda : " audio
}

# create new kvm server, work through the options. This function will probably see a lot more devlopment in future.
function newkvmerv {
	tree
	read -rp "Directory for new kvm: " dirkvm
	mkdir -p "$dirkvm"
	read -rp "size of vm, i.e. 30G : " size
	read -rp "image name, i.e. ubuntu.img : " image
	qemu-img create -f qcow2 "$dirkvm"/"$image" "$size" ;
	echo
	find "$PWD" -type f -name "*.iso"
	echo
	read -rp "iso file & full path: " iso
	memory
	cpu
	tree
	read -rp "Name of launch script, i.e. ubuntu.sh : " launch

	cat << EOF > "$dirkvm"/"$launch"
#!/bin/bash

sudo nohup \
qemu-system-x86_64 \
-enable-kvm \
-cdrom $iso \
-boot menu=on \
-drive file=$dirkvm/$image \
-m $memory \
-cpu host \
-smp $cpu \
-nic bridge,br=br0,model=virtio-net-pci \
>/dev/null 2>&1 &
EOF

	chmod 700 "$dirkvm"/"$launch"
	echo "KVM away to launch. Press ctrl+c now to avoid start up"
	sleep 5
	source "$dirkvm"/"$launch"
}

# Create new Desktop KVM
function newkvm {
	tree
	read -rp "Directory for new kvm: " dirkvm
	mkdir -p "$dirkvm"
	read -rp "size of vm, i.e. 30G : " size
	read -rp "image name, i.e. ubuntu.img : " image
	qemu-img create -f qcow2 "$dirkvm"/"$image" "$size" ;
	echo
	find "$PWD" -type f -name "*.iso"
	echo
	read -rp "iso file & full path: " iso
	memory
	cpu
	audio

	tree
	read -rp "Name of launch script, i.e. ubuntu.sh : " launch

  cat << EOF > "$dirkvm"/"$launch"
#!/bin/bash

sudo nohup \
qemu-system-x86_64 \
-enable-kvm \
-cdrom $iso \
-boot menu=on \
-drive file=$dirkvm/$image \
-m $memory \
-cpu host \
-smp $cpu \
-audiodev pa,id=snd0 \
-device $audio \
-device hda-output,audiodev=snd0 \
-nic bridge,br=br0,model=virtio-net-pci \
>/dev/null 2>&1 &
EOF
	chmod 700 "$dirkvm"/"$launch"
	echo "KVM away to launch. Press ctrl+c now to avoid start up"
	sleep 5
	source "$dirkvm"/"$launch"
}

# if you just want a quick way to find & execute your vm scripts, this is for you.
function oldkvm {
	echo
	i=0
  declare -a array
  while IFS= read -r vms
	do
   (( i++ ))
	 array[i]="$vms"

	 cat << EOF
        $i) ${array[i]}
EOF

	done <<<	"$(find "$PWD"/* -type f -name '*.sh')"
  echo
	read -rp "Select script number: " script
	source "${array[script]}"
}

# resize image size of kvm
function resizekvm {
	tree
	echo
	read -rp "Which qemu img kvm would you like to resize, include path: " image
	read -rp "Size of additional disk space, i.e. +10G : " size
	qemu-img resize "$image" "$size"
}

  cat << EOF
Would you like to create a new kvm or launch an old kvm?
note: requires sudo to launch from this script. ctrl + c and restart
with sudo ./master.sh

	1) New KVM
	2) Old KVM
	3) Resize KVM
	4) New KVM Server
	5) exit

EOF

  read -r oldnew

case "$oldnew" in
  1)
    newkvm ;;
  2)
    oldkvm ;;
  3)
    resizekvm ;;
  4)
    newkvmerv ;;
  5)
    exit 0 ;;
  *)
    echo "Incorrect option selected, exiting..."
esac

##### future functions section #####
# convert image formats
# qemu-img convert -f raw -O qcow2 input.img output.qcow2
#
#https://wiki.archlinux.org/title/QEMU
#https://man.archlinux.org/man/qemu.1
