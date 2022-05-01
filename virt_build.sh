#!/bin/sh

USERNAME=ubuntu
PASSWORD=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 10 | head -1)

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
