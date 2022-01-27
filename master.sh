#!/bin/bash

# Author: Jonny Peace
# check cpu threads and select the number required for a vm
function cpu {
	threads=$(grep -i processor /proc/cpuinfo | awk 'END{print $3+1}')
	echo
	echo "You have $threads CPU threads available for your VM"
	echo
	read -p "Number of CPU threads for VM: " cpu
}

# check available memory, and select the required ram for the vm
function memory {
	echo
	free -m
	read -p "Memory for VM, i.e. 4G: " memory
}

# check audio devices and select the appropriate device
# for servers, this will be unnecessary, i'll update this in future so it's not included for headless set-ups.
function audio {
	echo
	qemu-system-x86_64 -device help | grep hda
	echo
	read -p "Select audio output device, i.e. intel-hda : " audio
}

# create new kvm, work through the options. This function will probably see a lot more devlopment in future.
function newkvm {
	tree
	read -p "Directory for new kvm: " dirkvm
	mkdir -p $dirkvm
	read -p "size of vm, i.e. 30G : " size
	read -p "image name, i.e. ubuntu.img : " image
	qemu-img create -f qcow2 $dirkvm/$image $size ;
	echo
	find $(pwd) -type f -name "*.iso"
	echo
	read -p "iso file & full path: " iso
	memory
	cpu
	audio

	tree
	read -p "Name of launch script, i.e. ubuntu.sh : " launch

	echo -e "
#!/bin/bash

nohup \
qemu-system-x86_64 \
-enable-kvm \
-cdrom $iso \
-boot menu=on \
-drive file=$image \
-m $memory \
-cpu host \
-smp $cpu \
-audiodev pa,id=snd0 \
-device $audio \
-device hda-output,audiodev=snd0 \
-nic bridge,br=br0,model=virtio-net-pci \
>/dev/null 2>&1 &
" > $dirkvm/$launch

	chmod 700 $dirkvm/$launch
	echo "KVM away to launch. Press ctrl+c now to avoid start up"
	sleep 5
	cd $dirkvm
	/bin/bash $launch
}

# if you just want a quick way to find & execute your vm scripts, this is for you.
function oldkvm {
	echo
	i=0
	array=()
	p=$(find ./* -type f -name "*.sh")

	while IFS="" read -r q
	do
	 i=$(( i + 1 ))
	 array[i]=$(printf '%s\n' "$q")
	 echo "$i) ${array[i]}"
	done <<< $p

	read -p "Select script number: " script
	kvmdir=$(awk '{print}' <<< "${array[$script]}")
	echo "this is the kvmdir $kvmdir"

	dir=$(awk 'BEGIN{FS=OFS="/"}{NF--; print}' <<< $kvmdir)
	cd $dir
	kvm=$(awk -F/ '{print $NF}' <<< $kvmdir)
	/bin/bash $kvm
}

# resize image size of kvm
function resizekvm {
	tree
	echo
	read -p "Which qemu img kvm would you like to resize, include path: " image
	read -p "Size of additional disk space, i.e. +10G : " size
	qemu-img resize $image $size
}

echo -e "\nWould you like to create a new kvm or launch an old kvm? (1 or 2) \
	\n
	1) New KVM
	2) Old KVM
	3) Resize KVM
	4) exit
	"
echo
read oldnew

case $oldnew in
  1)
    newkvm ;;
  2)
    oldkvm ;;
  3)
    resizekvm ;;
  4)
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
