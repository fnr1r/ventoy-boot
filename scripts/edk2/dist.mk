HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk
include $(HERE)/info.mk

ifndef ARCH
$(error ARCH not specified)
endif

ifndef TOOLCHAIN
$(error TOOLCHAIN not defined)
endif

ARCH_upper := $(call uppercase,$(ARCH))

DIST_DIR := $(REPO_DIR)/dist
VTOY_DIR := $(DIST_DIR)/ventoy

BINS := Ventoy VtoyUtil
BIN_SRCS := $(foreach b,$(BINS),$(VTOY_DIR)/$b_$(ARCH).efi)

.PHONY: all dist
all: dist
	echo exit 1
dist: $(BINS)

define aaaa
.PHONY: $1
$1: $(VTOY_DIR)/$2_$(ARCH).efi
$(VTOY_DIR)/$2_$(ARCH).efi: Build/MdeModule/RELEASE_$(TOOLCHAIN)/$(ARCH_upper)/MdeModulePkg/Application/$1/$1/OUTPUT/$1.efi
	$(CP_FILE) $$< $$@
endef

$(foreach b,$(BINS),$(eval $(call aaaa,$b,$(call lowercase,$b))))

#$(VTOY_DIR)/%_$(ARCH).efi:
#	ls Build/MdeModule/RELEASE_GCC/$(ARCH_upper)/MdeModulePkg/Application/$(patsubst $(VTOY_DIR)/%_$(ARCH).efi,%,$@)/$(patsubst $(VTOY_DIR)/%_$(ARCH).efi,%,$@)/OUTPUT/$(patsubst $(VTOY_DIR)/%_$(ARCH).efi,%,$@).efi
#	#ls $<
#	exit 1
#	$(CP_FILE) $< $@
#$(VTOY_DIR)/ipxe.krn: src/bin/ipxe.lkrn
#	@mkdir -p $(dir $@)
#	$(CP_FILE) $< $@
