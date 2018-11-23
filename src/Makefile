# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2018 Denis Efremov <efremov@ispras.ru>. All Rights Reserved.

KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

all: build

ifneq ($(V),1)
MAKEFLAGS += --no-print-directory
endif

build:
	@$(MAKE) -C $(KERNELDIR) security/katechon/

style:
	$(KERNELDIR)/scripts/checkpatch.pl -f --max-line-length=4000 --codespell --color=always $(filter-out katechon.mod.c,$(wildcard *.c)) $(wildcard *.h)

check:
	@scan-build --html-title=Katechon -maxloop 100 --keep-going $(MAKE) -C $(KERNELDIR) C=2 CF="-D__CHECK_ENDIAN__" security/katechon/

coccicheck:
	@$(MAKE) -C $(KERNELDIR) coccicheck DEBUG_FILE="cocci.debug" MODE=report M=security/katechon/

format:
	@clang-format -style=file -i $(filter-out katechon.mod.c,$(wildcard *.c)) $(wildcard *.h)

.PHONY: all version.h module style check coccicheck