HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk

ifndef FORMAT
$(error FORMAT not specified)
endif

TARGET := $(firstword $(subst -, ,$(FORMAT)))
PLATFORM := $(lastword $(subst -, ,$(FORMAT)))

BUILDINFO_DIR := .build
BUILD_DIR := $(REPO_DIR)/build
PREFIXES_DIR := $(BUILD_DIR)/prefixes
PREFIX_DIR := $(PREFIXES_DIR)/$(FORMAT)

export FORMAT
export PREFIX_DIR

CONFIGURE_FLAGS := --disable-werror --target=$(TARGET) --with-platform=$(PLATFORM) --prefix="$(PREFIX_DIR)"

ifeq ($(TARGET),aarch64)
CROSS_COMPILE := aarch64-linux-gnu-
else ifeq ($(TARGET),mips64el)
CROSS_COMPILE := mips-linux-gnu-
TCC_FLAGS := -mabi=64 -Wno-error=cast-align -Wno-error=misleading-indentation
else
endif

ifneq ($(CROSS_COMPILE),)
export TARGET_CC := $(CROSS_COMPILE)gcc$(if $(TCC_FLAGS), $(TCC_FLAGS),)
export TARGET_OBJCOPY := $(CROSS_COMPILE)objcopy
export TARGET_STRIP := $(CROSS_COMPILE)strip
export TARGET_NM := $(CROSS_COMPILE)nm
export TARGET_RANLIB := $(CROSS_COMPILE)ranlib
endif

all: $(BUILD_DIR)/bin/grub-mkimage

$(BUILDINFO_DIR)/configured:
	./configure $(CONFIGURE_FLAGS)
	@mkdir -p $(dir $@)
	@touch $@

grub-mkimage: $(BUILDINFO_DIR)/configured
	+$(MAKE)

$(BUILD_DIR)/bin/grub-mkimage: grub-mkimage
	+$(MAKE) install
	+$(MAKE) -f $(HERE)/dist.mk
