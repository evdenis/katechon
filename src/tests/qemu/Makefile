.ONESHELL:
.PHONY: test clean katechon.new.patch

all: qemu

vm.img:
	./create-image.sh 'vm.img'

export KERNEL_VERSION?=5.2-rc4
export KERNEL=linux-$(KERNEL_VERSION)
export ARCHIVE?=gz
export KERNEL_ARCHIVE=$(KERNEL).tar.$(ARCHIVE)
export MODULE="$(KERNEL)/security/katechon"

$(KERNEL_ARCHIVE):
	wget --quiet https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/$@

$(KERNEL): | $(KERNEL_ARCHIVE)
	tar xf $(KERNEL_ARCHIVE)
	: > katechon.old.patch

katechon.new.patch:
	../../../contrib/kernel-tree/create-patch.sh > $@

katechon.old.patch:
	touch $@

$(MODULE): katechon.old.patch katechon.new.patch | $(KERNEL)
	cd $(KERNEL)
	patch -R -f -p 1 < ../katechon.old.patch
	patch -f -p 1 < ../katechon.new.patch
	cd ..
	mv katechon.new.patch katechon.old.patch

upstream-kasan.config:
	wget --quiet https://raw.githubusercontent.com/google/syzkaller/master/dashboard/config/upstream-kasan.config

$(KERNEL)/arch/x86_64/boot/bzImage $(MODULE)/built-in.a: $(MODULE) upstream-kasan.config
	cd $(KERNEL)
	cp ../upstream-kasan.config .config
	sed -i '/^CONFIG_SECURITY_SELINUX/d;/^CONFIG_DEFAULT_SECURITY/d;/KATECHON/d' .config
	echo '# CONFIG_SECURITY_SELINUX is not set\nCONFIG_SECURITY_KATECHON=y\nCONFIG_DEFAULT_SECURITY_KATECHON=y\nCONFIG_DEFAULT_SECURITY="katechon"' >> .config
	make olddefconfig
	make -j6

qemu: $(KERNEL)/arch/x86_64/boot/bzImage vm.img

clean:
	-rm -fr $(KERNEL) $(KERNEL_ARCHIVE) *.id_rsa.pub *.id_rsa vm.img katechon.*.patch upstream-kasan.config

