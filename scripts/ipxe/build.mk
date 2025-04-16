HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk

ifndef ARCH
$(error ARCH not specified)
endif

ifneq ($(ARCH),i386)
$(error ipxe is only built for i386 pc)
endif

.PHONY: all build
all: build
build: src/bin/ipxe.lkrn

src/%:
	$(MAKE) -C src $(patsubst src/%,%,$@) BIOS_MODE=BISO NO_WERROR=1
