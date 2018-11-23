#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2018 Denis Efremov <efremov@ispras.ru> All Rights Reserved.
# Based on WireGuard sources by Jason A. Donenfeld <Jason@zx2c4.com>.

K="$1"
KT="$(readlink -f "$(dirname "$(readlink -f "$0")")/../../src/")"

if [[ ! -e $K/security/Kconfig ]]; then
	echo "You must specify the location of kernel sources as the first argument." >&2
	exit 1
fi

ln -sfT "$KT" "$K/security/katechon"
sed -i "/^obj-\\\$(CONFIG_SECURITY_SELINUX).*+=/a obj-\$(CONFIG_SECURITY_KATECHON)\t+= katechon/" "$K/security/Makefile"
sed -i "/^subdir-\\\$(CONFIG_SECURITY_SELINUX).*+=/a subdir-\$(CONFIG_SECURITY_KATECHON)\t+= katechon" "$K/security/Makefile"
sed -i "/^source security\/selinux\/Kconfig/a source security\/katechon\/Kconfig" "$K/security/Kconfig"
sed -i "/^\tdefault DEFAULT_SECURITY_SELINUX if SECURITY_SELINUX/a \\\tdefault DEFAULT_SECURITY_KATECHON if SECURITY_KATECHON" "$K/security/Kconfig"
sed -i '/default "selinux" if DEFAULT_SECURITY_SELINUX/a \\tdefault "katechon" if DEFAULT_SECURITY_KATECHON' "$K/security/Kconfig"
sed -i '/bool "SELinux" if SECURITY_SELINUX=y/a \\n\tconfig DEFAULT_SECURITY_KATECHON\n\t\tbool "Katechon" if SECURITY_KATECHON=y' "$K/security/Kconfig"
