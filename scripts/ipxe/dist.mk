HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk

ifndef ARCH
$(error ARCH not specified)
endif

ifneq ($(ARCH),i386)
$(error ipxe is only built for i386 pc)
endif

DIST_DIR := $(REPO_DIR)/dist
VTOY_DIR := $(DIST_DIR)/ventoy

.PHONY: all dist
all: dist
dist: $(VTOY_DIR)/ipxe.krn

$(VTOY_DIR)/ipxe.krn: src/bin/ipxe.lkrn
	@mkdir -p $(dir $@)
	$(CP_FILE) $< $@
