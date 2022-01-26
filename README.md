# qemu-kvm script and netplan bridge for Ubuntu.

The master script works inside the directory of the qemu-kvm virtual machines.

An example structure...

virtual-machine-directory
> master.sh
  endeav-vm-directory
   > endeavour.img
   > EndeavourOS_Atlantis_neo-21_5.iso
   > endo.sh
  ubuntu20.4-vm-directory
   > ubuntu-20.04.3-desktop-amd64.iso
   > ubuntu.img
   > ubuntu.sh

I have provided a simple netplan yaml example, where dhcp is enabled on both bridge and enp3s0 on ubuntu

The script should be self explanatory with the user prompts. I do plan on devloping it further as i use it more and find
more options to include. Passthrough devices might be next.
