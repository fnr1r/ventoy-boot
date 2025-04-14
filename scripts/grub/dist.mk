HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk
include $(SCRIPTS_DIR)/grub_modules.mk

ifndef FORMAT
$(error FORMAT not specified)
endif

ifndef PREFIX_DIR
$(error PREFIX_DIR not specified)
endif

DIST_DIR := $(REPO_DIR)/dist
#TARGET_DIR := $(REPO_DIR)/$(FORMAT)
WORK_DIR := $(REPO_DIR)/build/work/$(FORMAT)

GRUB_PREFIX := (,2)/grub

TARGET := $(firstword $(subst -, ,$(FORMAT)))
PLATFORM := $(lastword $(subst -, ,$(FORMAT)))

ifeq ($(FORMAT), i386-pc)
MKIMAGE_MODULES := $(ALL_MODULES_X86_LEGACY)
COMPRESS_MODULES := false
else ifeq ($(FORMAT), x86_64-efi)
MKIMAGE_MODULES := $(ALL_MODULES_X86_UEFI)
COMPRESS_MODULES := false
else ifeq ($(FORMAT), i386-efi)
MKIMAGE_MODULES := $(ALL_MODULES_X86_UEFI)
COMPRESS_MODULES := false
else ifeq ($(FORMAT), aarch64-efi)
MKIMAGE_MODULES := $(ALL_MODULES_RISC)
COMPRESS_MODULES := true
else ifeq ($(FORMAT), mips64el-efi)
MKIMAGE_MODULES := $(ALL_MODULES_RISC)
COMPRESS_MODULES := true
else
$(error Unsupported: $(FORMAT))
endif

ifeq ($(TARGET), aarch64)
GRUB_ARCH := arm64
else
GRUB_ARCH := $(TARGET)
endif

GRUB_FORMAT := $(GRUB_ARCH)-$(PLATFORM)

ifeq ($(PLATFORM), pc)
	BOOT_EXEC := core.img
	NETDIR_MODULES := $(MKIMAGE_MODULES) $(NET_MODULES_LEGACY)
else
	BOOT_EXEC := $(shell bash $(SCRIPTS_DIR)/architectures.sh get_boot_file_name $(FORMAT))
	NETDIR_MODULES := $(MKIMAGE_MODULES) $(NET_MODULES_UEFI)
endif

$(info FORMAT: $(FORMAT))
$(info BOOT_EXEC: $(BOOT_EXEC))

GRUB_LIB := $(wildcard $(PREFIX_DIR)/lib/grub/$(GRUB_FORMAT)/*)

.PHONY: all dist modules modules
all: dist
dist: $(DIST_DIR)/EFI/BOOT/$(BOOT_EXEC) modules
modules: $(WORK_DIR)/pxe
	bash $(HERE)/copy_modules.sh $</$(GRUB_FORMAT) $(GRUB_FORMAT)

ifeq ($(PLATFORM), efi)
$(DIST_DIR)/EFI/BOOT/$(BOOT_EXEC): $(WORK_DIR)/boot/$(BOOT_EXEC)
	@mkdir -p $(dir $@)
	cp -a $< $@
else
.PHONY: dist/EFI/BOOT/$(BOOT_EXEC)
$(DIST_DIR)/EFI/BOOT/$(BOOT_EXEC): $(WORK_DIR)/boot/$(BOOT_EXEC)
endif

ifeq ($(COMPRESS_MODULES), true)
$(DIST_DIR)/grub/$(GRUB_FORMAT)/%.mod: build/pxe/$(GRUB_FORMAT)/%.mod
	@mkdir -p $(dir $@)
	cat $< | xz > $@
else
$(DIST_DIR)/grub/$(GRUB_FORMAT)/%.mod: build/pxe/$(GRUB_FORMAT)/%.mod
	@mkdir -p $(dir $@)
	cp -a $< $@
endif

$(DIST_DIR)/grub/$(GRUB_FORMAT)/%.lst: build/pxe/$(GRUB_FORMAT)/%.lst
	@mkdir -p $(dir $@)
	cp -a $< $@

build: $(WORK_DIR)/boot/$(BOOT_EXEC) $(WORK_DIR)/pxe

$(WORK_DIR)/boot/$(BOOT_EXEC): $(PREFIX_DIR)/bin/grub-mkimage $(GRUB_LIB)
	@mkdir -p $(dir $@)
	$(PREFIX_DIR)/bin/grub-mkimage \
		--directory "$(PREFIX_DIR)/lib/grub/$(GRUB_FORMAT)" \
		--prefix "$(GRUB_PREFIX)" \
		--output "$@" \
		--format "$(GRUB_FORMAT)" \
		--compression 'auto' \
		$(MKIMAGE_MODULES)

$(WORK_DIR)/pxe: $(PREFIX_DIR)/bin/grub-mknetdir $(GRUB_LIB)
	@mkdir -p $@
	$(PREFIX_DIR)/bin/grub-mknetdir \
		--directory "$(PREFIX_DIR)/lib/grub/$(GRUB_FORMAT)" \
		--modules="$(NETDIR_MODULES)" \
		--net-directory="$@" \
		--subdir="" \
		--locales=en@quot
