#!/bin/bash


yum -y install nfs-utils
systemctl enable firewalld.service --now
echo "192.168.56.10:/srv/share /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0">>/etc/fstab
systemctl daemon-reload 
systemctl restart remote-fs.target
