#!/bin/sh

echo 'Write Hostname'
read hostname

sudo virt-install \
     --name $hostname \
     --hvm \
     --virt-type kvm \
     --ram 2048 \
     --vcpus 2 \
     --arch x86_64 \
     --os-type linux \
     --os-variant ubuntu18.04 \
     --boot hd \
     --disk path=/home/shared/images/ubuntu_$hostname.qcow2 \
     --network bridge=br0 \
     --graphics none \
     --serial pty \
     --console pty
