# Update the box
DEBIAN_FRONTEND=noninteractive apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
# apt-get -y install linux-headers-$(uname -r) build-essential
# apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev
DEBIAN_FRONTEND=noninteractive apt-get -y install curl unzip resolvconf console-setup apt-transport-https vim wget htop parted traceroute ifupdown

# Tweak sshd to prevent DNS resolution (speed up logins)
# echo 'UseDNS no' >> /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config

# https://communities.vmware.com/thread/514376
# vmwgfx.enable_fbdev=1

# https://kb.vmware.com/s/article/2053145
echo "options vmw_pvscsi cmd_per_lun=254 ring_pages=32" > /etc/modprobe.d/pvscsi

# fixing eth0 naming
sed -i 's/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0 ipv6.disable=1 netcfg\/do_not_use_netplan=true\"/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Enable ESX timesync
vmware-toolbox-cmd timesync enable

# disable netplan
apt -y purge netplan.io
systemctl disable systemd-resolved
cat >/etc/network/interfaces <<EOL
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp
pre-up sleep 2
EOL

if fdisk -l|grep -i "/dev/sdb" > /dev/null; then
# https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux
# https://askubuntu.com/questions/384062/how-do-i-create-and-tune-an-ext4-partition-from-the-command-line
  echo "mount sdb"
  parted /dev/sdb mklabel gpt
  parted -a opt /dev/sdb mkpart primary ext4 0% 100%
  mkfs.ext4 -L efs /dev/sdb1
  mkdir -p /mnt/efs
  echo "#" >> /etc/fstab
  echo "LABEL=efs /mnt/efs ext4 noatime,nodiratime,barrier=0,nobh,errors=remount-ro 0 1" >> /etc/fstab
  mount -a
  mkdir -p /mnt/efs/elasticsearch
fi