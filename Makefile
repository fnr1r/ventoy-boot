include scripts/here.mk
include $(SCRIPTS_DIR)/shared.mk

PREPARABLE_SUBPROJECTS := edk2 grub
SUBPROJECTS := $(PREPARABLE_SUBPROJECTS) ipxe
STAGES := prepare build

_overlays := $(shell ls build-overlay)
_overlays_base := $(filter %-base,$(_overlays))
_overlays_build := $(filter-out %-base,$(_overlays))

define ovl_clean
	-sudo rm -rf $(foreach a,$1,build-overlay/$a/work/index)
	-rm -rf $(addprefix build-overlay/,$1)
endef

.PHONY: all build clean clean-all
all: build
build: $(SUBPROJECTS)
prepare: $(addprefix prepare-, $(PREPARABLE_SUBPROJECTS))
clean:
	-rm -r dist build
	-rm -r build-work
	$(call ovl_clean,$(_overlays_build))
clean-all: clean
	$(call ovl_clean,$(_overlays_base))

.PHONY: $(SUBPROJECTS)
edk2: $(addsuffix -edk2,$(STAGES))
grub: $(addsuffix -grub,$(STAGES))
ipxe: build-ipxe

.PHONY: $(addprefix prepare-, $(PREPARABLE_SUBPROJECTS))
$(addprefix prepare-, $(PREPARABLE_SUBPROJECTS)):
	+env UPPERDIR="$(patsubst prepare-%,%-base,$@)" \
		bash $(SCRIPTS_DIR)/run_in_overlay.sh \
		$(MAKE) -C $(patsubst prepare-%,%,$@) \
		-f $(SCRIPTS_DIR)/$(patsubst prepare-%,%,$@)/prepare.mk

.PHONY: $(addprefix build-, $(SUBPROJECTS))
$(addprefix build-, $(SUBPROJECTS)): prepare
	+$(MAKE) -f $(SCRIPTS_DIR)/$(patsubst build-%,%,$@)/build.outer.mk
