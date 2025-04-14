HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk

.PHONY: all build
all: build
build: $(EDK2_ARCHES)

.PHONY: $(EDK2_ARCHES)
$(EDK2_ARCHES):
	+env ARCH="$@" LOWERDIRS="edk2-base" UPPERDIR="edk2-$@" \
		bash $(SCRIPTS_DIR)/run_in_overlay.sh \
		$(MAKE) -C edk2 \
		-f $(SCRIPTS_DIR)/edk2/build.mk
