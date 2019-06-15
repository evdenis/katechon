// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (C) 2019 Denis Efremov <efremov@ispras.ru>. All Rights Reserved.
 */

#include "common.h"

#include <linux/lsm_hooks.h>


int katechon_enabled __lsm_ro_after_init = 1;

/**
 * katechon_init - Register Katechon as a LSM module.
 *
 * Returns 0.
 */
static int __init katechon_init(void)
{
	//security_add_hooks(katechon_hooks, ARARY_SIZE(katechon_hooks), "katechon");
	pr_info("LSM initialized ( " KATECHON_VERSION " )\n");

	return 0;
}

DEFINE_LSM(katechon) = {
	.name = "katechon",
	.enabled = &katechon_enabled,
	.init = katechon_init,
};
