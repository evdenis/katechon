#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2019 Denis Efremov <efremov@ispras.ru> All Rights Reserved.
# Based on WireGuard sources by Jason A. Donenfeld <Jason@zx2c4.com>.

shopt -s globstar

KT="$(readlink -f "$(dirname "$(readlink -f "$0")")/../../src/")"

for i in "$KT"/**/{*.c,*.h} "$KT/Kbuild" "$KT/Kconfig"; do
	[[ $i == "$KT/tools/"* || $i == "$KT/tests/"* ]] && continue
	diff -u /dev/null "$i" | sed "s:${KT}:b/security/katechon:;s:Kbuild:Makefile:"
done

cat <<_EOF
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -231,6 +231,7 @@ config STATIC_USERMODEHELPER_PATH
 	  specify an empty string here (i.e. "").
 
 source "security/selinux/Kconfig"
+source "security/katechon/Kconfig"
 source "security/smack/Kconfig"
 source "security/tomoyo/Kconfig"
 source "security/apparmor/Kconfig"
@@ -243,6 +244,7 @@ source "security/integrity/Kconfig"
 choice
 	prompt "First legacy 'major LSM' to be initialized"
 	default DEFAULT_SECURITY_SELINUX if SECURITY_SELINUX
+	default DEFAULT_SECURITY_KATECHON if SECURITY_KATECHON
 	default DEFAULT_SECURITY_SMACK if SECURITY_SMACK
 	default DEFAULT_SECURITY_TOMOYO if SECURITY_TOMOYO
 	default DEFAULT_SECURITY_APPARMOR if SECURITY_APPARMOR
@@ -260,6 +262,9 @@ choice
 	config DEFAULT_SECURITY_SELINUX
 		bool "SELinux" if SECURITY_SELINUX=y
 
+	config DEFAULT_SECURITY_KATECHON
+		bool "Katechon" if SECURITY_KATECHON=y
+
 	config DEFAULT_SECURITY_SMACK
 		bool "Simplified Mandatory Access Control" if SECURITY_SMACK=y
 
@@ -279,6 +284,7 @@ config LSM
 	default "yama,loadpin,safesetid,integrity,smack,selinux,tomoyo,apparmor" if DEFAULT_SECURITY_SMACK
 	default "yama,loadpin,safesetid,integrity,apparmor,selinux,smack,tomoyo" if DEFAULT_SECURITY_APPARMOR
 	default "yama,loadpin,safesetid,integrity,tomoyo" if DEFAULT_SECURITY_TOMOYO
+	default "yama,loadpin,safesetid,integrity,katechon" if DEFAULT_SECURITY_KATECHON
 	default "yama,loadpin,safesetid,integrity" if DEFAULT_SECURITY_DAC
 	default "yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"
 	help
diff --git a/security/Makefile b/security/Makefile
index c598b904938f..9274b86e331b 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -5,6 +5,7 @@
 
 obj-\$(CONFIG_KEYS)			+= keys/
 subdir-\$(CONFIG_SECURITY_SELINUX)	+= selinux
+subdir-\$(CONFIG_SECURITY_KATECHON)	+= katechon
 subdir-\$(CONFIG_SECURITY_SMACK)		+= smack
 subdir-\$(CONFIG_SECURITY_TOMOYO)        += tomoyo
 subdir-\$(CONFIG_SECURITY_APPARMOR)	+= apparmor
@@ -20,6 +21,7 @@ obj-\$(CONFIG_MMU)			+= min_addr.o
 obj-\$(CONFIG_SECURITY)			+= security.o
 obj-\$(CONFIG_SECURITYFS)		+= inode.o
 obj-\$(CONFIG_SECURITY_SELINUX)		+= selinux/
+obj-\$(CONFIG_SECURITY_KATECHON)	+= katechon/
 obj-\$(CONFIG_SECURITY_SMACK)		+= smack/
 obj-\$(CONFIG_AUDIT)			+= lsm_audit.o
 obj-\$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/
_EOF
