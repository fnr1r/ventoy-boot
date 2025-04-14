HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk

.PHONY: all build
all: build
build: $(IPXE_ARCHES)

.PHONY: $(IPXE_ARCHES)
$(IPXE_ARCHES):
	+env ARCH="$@" UPPERDIR="ipxe-$@" \
		bash $(SCRIPTS_DIR)/run_in_overlay.sh \
		$(MAKE) -C ipxe \
		-f $(SCRIPTS_DIR)/ipxe/build.mk
