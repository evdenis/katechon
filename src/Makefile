# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2019 Denis Efremov <efremov@ispras.ru>. All Rights Reserved.

KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

all: build

ifneq ($(V),1)
MAKEFLAGS += --no-print-directory
endif

version.h:
	@ver="/* SPDX-License-Identifier: GPL-2.0 */\n\
	#define KATECHON_VERSION \"$$(git describe --dirty 2>/dev/null)\"" && \
	[ "$$(cat version.h 2>/dev/null)" != "$$ver" ]                     && \
	echo "$$ver" > version.h                                           && \
	git update-index --assume-unchanged version.h || true

build: version.h
	@$(MAKE) -C $(KERNELDIR) security/katechon/

style:
	$(KERNELDIR)/scripts/checkpatch.pl -f --max-line-length=4000 --codespell --color=always $(filter-out katechon.mod.c,$(wildcard *.c)) $(wildcard *.h)

check:
	@scan-build --html-title=Katechon -maxloop 100 --keep-going $(MAKE) -C $(KERNELDIR) C=2 CF="-D__CHECK_ENDIAN__" security/katechon/

coccicheck:
	@$(MAKE) -C $(KERNELDIR) coccicheck DEBUG_FILE="cocci.debug" MODE=report M=security/katechon/

format:
	@clang-format -style=file -i $(filter-out katechon.mod.c,$(wildcard *.c)) $(wildcard *.h)

remove_specs:
	# Remove ACSL specs.
	@$(PWD)/../contrib/remove_acsl_specs.pl $(shell find $(PWD) -maxdepth 2 -type f -name '*.[ch]')
	# Remove include directives of spec headers.
	@find $(PWD) -maxdepth 2 -type f -name '*.[ch]' -exec perl -i -pe 's!\s*#\s*include\s*"spec_.*\n!!g' {} \;
	# Remove spec headers.
	@find $(PWD) -maxdepth 2 -type f -name '*.[ch]' -name 'spec_*.[ch]' -delete

cloc:
	@cloc --skip-uniqueness --by-file $(filter-out katechon.mod.c,$(wildcard *.c)) $(wildcard *.h)

clean:
	@find  . \( -name .git -o -name tests \) -prune -o               \
	        \( -name '*.[aios]' -o -name '*.ko' -o -name '.*.cmd'    \
	        -o -name '*.ko.*'                                        \
	        -o -name '*.dtb' -o -name '*.dtb.S' -o -name '*.dt.yaml' \
	        -o -name '*.dwo' -o -name '*.lst'                        \
	        -o -name '*.su'                                          \
	        -o -name '.*.d' -o -name '.*.tmp' -o -name '*.mod.c'     \
	        -o -name '*.lex.c' -o -name '*.tab.[ch]'                 \
	        -o -name '*.asn1.[ch]'                                   \
	        -o -name '*.symtypes' -o -name 'modules.order'           \
	        -o -name modules.builtin -o -name '.tmp_*.o.*'           \
	        -o -name '*.c.[012]*.*'                                  \
	        -o -name '*.ll'                                          \
	        -o -name 'Module.symvers'                                \
	        -o -name '*.gcno' \) -type f -print | xargs rm -f

.PHONY: all version.h build style check coccicheck format remove_specs cloc clean
