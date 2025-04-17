HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk
include $(HERE)/info.mk

ifndef ARCH
$(error ARCH not specified)
endif

ifeq ($(ARCH), aarch64)
export GCC48_AARCH64_PREFIX=aarch64-linux-gnu-
TOOLCHAIN := GCC48
else
TOOLCHAIN := GCC
endif

export TOOLCHAIN

ifeq ($(ARCH), aarch64)
BUILD_DEPS := $(BUILDINFO_DIR)/aarch64patches
#$(addprefix $(BUILDINFO_DIR)/,nostackprotector nowerror)
else
BUILD_DEPS :=
endif

TARGET_DIR := $(REPO_DIR)/dist/ventoy

.PHONY: all build
all: build
build: $(BUILD_DEPS)
	+bash -c ". edksetup.sh; \
		build -a $(call uppercase,$(ARCH)) -b RELEASE -t $(TOOLCHAIN) -p MdeModulePkg/MdeModulePkg.dsc"
	+$(MAKE) -f $(HERE)/dist.mk

Conf/tools_def.txt:
	bash -c ". edksetup.sh"

$(BUILDINFO_DIR)/aarch64patches: Conf/tools_def.txt
	sed -e 's| -mstack-protector-guard=global||g' -i $<
	sed -e 's| -Werror||g' -i $<
	@touch $@
