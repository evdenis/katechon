// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (C) 2018 Denis Efremov <efremov@ispras.ru>. All Rights Reserved.
 */

#include "version.h"

#include <linux/lsm_hooks.h>

/**
 * katechon_init - Register Katechon as a LSM module.
 *
 * Returns 0.
 */
static int __init katechon_init(void)
{
	if (!security_module_enable("katechon"))
		return 0;

	pr_info("LSM initialized ( " KATECHON_VERSION " )\n");

	return 0;
}

DEFINE_LSM(katechon) = {
	.name = "katechon",
	.init = katechon_init,
};
