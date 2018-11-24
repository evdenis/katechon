#!/bin/bash
# Copyright 2018 syzkaller project authors. All rights reserved.
# Use of this source code is governed by GPL 2 LICENSE that can be found in the LICENSE file.

set -eux

# Create a minimal Debian distribution in a directory.
RELEASE=stretch
DIR=stretch
IMAGE="${1:-vm.img}"

sudo rm -rf $DIR $IMAGE $RELEASE.id_rsa $RELEASE.id_rsa.pub
mkdir -p $DIR
sudo debootstrap --include=openssh-server,curl,tar,gcc,libc6-dev,time,strace,sudo,less,psmisc $RELEASE $DIR

# Set some defaults and enable promtless ssh to the machine for root.
sudo sed -i '/^root/ { s/:x:/::/ }' $DIR/etc/passwd
echo 'T0:23:respawn:/sbin/getty -L ttyS0 115200 vt100' | sudo tee -a $DIR/etc/inittab
printf '\nauto eth0\niface eth0 inet dhcp\n' | sudo tee -a $DIR/etc/network/interfaces
echo '/dev/root / ext4 defaults 0 0' | sudo tee -a $DIR/etc/fstab
echo 'debugfs /sys/kernel/debug debugfs defaults 0 0' | sudo tee -a $DIR/etc/fstab
echo 'securityfs /sys/kernel/security securityfs defaults 0 0' | sudo tee -a $DIR/etc/fstab
echo 'configfs /sys/kernel/config/ configfs defaults 0 0' | sudo tee -a $DIR/etc/fstab
echo 'binfmt_misc /proc/sys/fs/binfmt_misc binfmt_misc defaults 0 0' | sudo tee -a $DIR/etc/fstab
echo "kernel.printk = 7 4 1 3" | sudo tee -a $DIR/etc/sysctl.conf
echo -en "127.0.0.1\tlocalhost\n" | sudo tee $DIR/etc/hosts
echo "nameserver 8.8.8.8" | sudo tee -a $DIR/etc/resolve.conf
ssh-keygen -f $RELEASE.id_rsa -t rsa -N ''
sudo mkdir -p $DIR/root/.ssh/
cat $RELEASE.id_rsa.pub | sudo tee $DIR/root/.ssh/authorized_keys

# Build a disk image
dd if=/dev/zero of=$IMAGE bs=1M seek=2047 count=1
sudo mkfs.ext4 -F $IMAGE
sudo mkdir -p /mnt/$DIR
sudo mount -o loop $IMAGE /mnt/$DIR
sudo cp -a $DIR/. /mnt/$DIR/.
sudo umount /mnt/$DIR
