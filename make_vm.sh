#!/bin/sh

USERNAME=ubuntu
PASSWORD=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 10 | head -1)

echo 'virt-builder'
sudo virt-builder ubuntu-18.04 \
     --format qcow2 \
     --hostname $PASSWORD \
     --timezone Asia/Tokyo \
     --append-line '/etc/default/grub:GRUB_CMDLINE_LINUX="console=ttyS0,115200"' \
     --run-command 'update-grub' \
     --root-password password:password \
     --firstboot-command " \
     bash -c 'echo -n > /etc/machine-id' \
     dpkg-reconfigure openssh-server; \
     useradd -m -G sudo,operator -s /bin/bash $USERNAME; \
     echo '$USERNAME:$PASSWORD' | chpasswd; \
     chown -R $USERNAME /home/$USERNAME; \
     perl -pi -e 's/^%sudo.*$/%sudo     ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers; \
     perl -p -i.bak -e 's%https?://(?!security)[^ \t]+%http://jp.archive.ubuntu.com/ubuntu/%g' /etc/apt/sources.list; \    
     reboot \
     " \
     -o /home/shared/images/ubuntu_$PASSWORD.qcow2

echo 'virt-install'

sudo virt-install \
     --name $PASSWORD \
     --hvm \
     --virt-type kvm \
     --ram 2048 \
     --vcpus 2 \
     --arch x86_64 \
     --os-type linux \
     --os-variant ubuntu18.04 \
     --boot hd \
     --disk path=/home/shared/images/ubuntu_$PASSWORD.qcow2 \
     --network bridge=br0 \
     --graphics none \
     --serial pty \
     --console pty
