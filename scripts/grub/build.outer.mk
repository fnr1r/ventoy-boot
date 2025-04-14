HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk

.PHONY: all build
all: build
build: $(GRUB_FORMATS)

.PHONY: $(GRUB_FORMATS)
$(GRUB_FORMATS):
	+env FORMAT="$@" LOWERDIRS="grub-base" UPPERDIR="grub-$@" \
		bash $(SCRIPTS_DIR)/run_in_overlay.sh \
		$(MAKE) -C grub \
		-f $(SCRIPTS_DIR)/grub/build.mk
