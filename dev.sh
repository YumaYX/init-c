#!/bin/bash

# pre-prepare
#curl -O https://ftp.riken.jp/Linux/almalinux/9.4/isos/x86_64/AlmaLinux-9-latest-x86_64-dvd.iso

# repos
mkdir /root/repos
mv /etc/yum.repos.d/* /root/repos

cat <<DVDREPO >/etc/yum.repos.d/dvd.repo
[DVD-REPO]
name=DVD-BaseOS
baseurl=file:///media/BaseOS/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9

[DVD-REPO2]
name=DVD-AppStream
baseurl=file:///media/AppStream/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9
DVDREPO

cat <<DVDMOUNT >/root/dvd_mount.sh
mount /dev/sr0 /media
#mount -o loop /tmp/AlmaLinux*.iso /media
DVDMOUNT
sh /root/dvd_mount.sh

# packages
dnf -y group install development
dnf -y group install "Server with GUI"
systemctl set-default graphical.target
cat <<PKGS | xargs dnf -y
vim
make
ruby
rubygem-*
firewalld
httpd
sudo
git
procps
gcc
ansible-core
PKGS

systemctl enable --now firewalld
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

# user
user=yuma
useradd -m $user

#######################################
sudo su - $user -c 'whoami'

