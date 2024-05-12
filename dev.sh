#!/bin/bash

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
mount /dev/sr0 /media || mount -o loop /tmp/AlmaLinux*.iso /media
DVDMOUNT
sh /root/dvd_mount.sh

# packages
dnf -y group install development
dnf -y group install "Server with GUI"
systemctl set-default graphical.target
cat <<PKGS | xargs dnf -y install
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
expect
ansible-core
PKGS

systemctl enable --now firewalld
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

# user
user=yuma
useradd -m $user
echo "${user} ALL=(ALL) ALL" > /etc/sudoers.d/${user}

cat <<'USERP' >/tmp/passwd.sh
#!/bin/sh

user=$1
expect -c "
spawn passwd $user
expect New\ password;  send $user; send \n
expect Retype\ ; send $user; send \n;
expect eof exit 0
"
USERP
LANG=C sh /tmp/passwd.sh $user

# nfs
dnf -y install nfs-utils
echo '/nfs *(rw,no_root_squash)' > /etc/exports
mkdir /nfs
chown -R nobody. /nfs
chmod -R 777 /nfs
exportfs -av
systemctl enable --now rpcbind nfs-server
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service={nfs3,mountd,rpc-bind}
firewall-cmd --reload
systemctl daemon-reload
ln -s /nfs /work

# workspace
mkdir -p /work/{lib,download,data,sandbox,output,bin}

