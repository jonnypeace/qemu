# qemu-kvm script and netplan bridge for Ubuntu.

Warning: This README is old and requires updates. With the switch to wayland, i've switched from dmenu to wofi.

Although I have proxmox servers, I have often wanted a quick repeatable way to deploy some sensible
virtual machines on linux desktops that I use, and hence... this repo.

You will need qemu..
~~~
sudo apt install qemu
~~~

The master script works inside the directory of the qemu-kvm virtual machines.

An example structure...

~~~
vm-directory
├── endo-vm-directory
│   ├── endeavour.img
│   ├── EndeavourOS_Atlantis_neo-21_5.iso
│   └── endo.sh
├── master.sh
└── ubuntu20.4-vm-directory
    ├── ubuntu-20.04.3-desktop-amd64.iso
    ├── ubuntu.img
    └── ubuntu.sh
~~~

I have provided a simple netplan yaml example, where dhcp is enabled on both bridge and enp3s0 on ubuntu

The script should be self explanatory with the user prompts. I do plan on devloping it further as i use it more and find
more options to include. Passthrough devices, convert image format, maybe integrate some of my crypto work. 

If you don't want to bridge, and/or to help with troubleshooting, remove this line in master.sh, and any other vm scripts generated.

~~~
-nic bridge,br=br0,model=virtio-net-pci \
~~~

If you want bridge to work in ubuntu using netplan, copy this config and edit as necessary into /etc/qemu/
~~~
# might need to create the directory like i did.
sudo mkdir -p /etc/qemu

# Minimum permissions required for bridge to work.
sudo chmod 755 /etc/qemu

# copy config to correct directory
cp etc-qemu-bridge.conf /etc/qemu/bridge.conf
~~~
vm-dmenu.sh and skipfiles.txt work together, and optional extra for fast deployment of VM's using a keyboard shortcut.
This excludes the need to open a terminal and will list the scripts in this qemu-kvm project.
In ubuntu, you will need dmenu...
~~~
sudo apt install dmenu
~~~
