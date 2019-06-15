// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (C) 2019 Denis Efremov <efremov@ispras.ru>. All Rights Reserved.
 */

#include "version.h"

#include <linux/security.h>

static ssize_t katechon_read(struct file *filp, char __user *buf,
			    size_t count, loff_t *ppos)
{
	char temp[80];
	ssize_t rc;

	if (*ppos != 0)
		return 0;

	sprintf(temp, "%s", KATECHON_VERSION);
	rc = simple_read_from_buffer(buf, count, ppos, temp, strlen(temp));

	return rc;
}

static ssize_t katechon_write(struct file *file, const char __user *buf,
			     size_t count, loff_t *ppos)
{
	return 0;
}

static const struct file_operations katechon_operations = {
	.read	= katechon_read,
	.write	= katechon_write,
};


/**
 * katechonfs_init - Initialize /sys/kernel/security/katechon/ interface.
 *
 * Returns 0.
 */
static int __init katechonfs_init(void)
{
	int error = 0;
	struct dentry *katechon_dir = NULL;
	struct dentry *katechon_version = NULL;

	katechon_dir = securityfs_create_dir("katechon", NULL);
	if (!katechon_dir || IS_ERR(katechon_dir))
		return -EFAULT;

	katechon_version = securityfs_create_file("version", 0400, katechon_dir,
						  NULL, &katechon_operations);
	if (!katechon_version || IS_ERR(katechon_version)) {
		error = -EFAULT;
		goto out;
	}

	return 0;
out:
	securityfs_remove(katechon_version);
	securityfs_remove(katechon_dir);
	return error;
}

fs_initcall(katechonfs_init);
