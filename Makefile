include scripts/here.mk
include $(SCRIPTS_DIR)/shared.mk

SUBPROJECTS := edk2 grub
STAGES := prepare build

.PHONY: all build clean clean-all
all: build
build: $(SUBPROJECTS)
prepare: $(addprefix prepare-, $(SUBPROJECTS))
clean:
	-rm -r dist build
	-sudo rm -rf $(foreach f,$(FORMATS),build-overlay/$f/work/index)
	-rm -rf $(addprefix build-overlay/,$(FORMATS))
	-rm -r build-work
clean-all: clean
	-sudo rm -rf build-overlay/bootstrap/work/index
	-rm -rf build-overlay

.PHONY: $(SUBPROJECTS)
edk2: $(addsuffix -edk2,$(STAGES))
grub: $(addsuffix -grub,$(STAGES))

.PHONY: $(addprefix prepare-, $(SUBPROJECTS))
$(addprefix prepare-, $(SUBPROJECTS)):
	+env UPPERDIR="$(patsubst prepare-%,%-base,$@)" \
		bash $(SCRIPTS_DIR)/run_in_overlay.sh \
		$(MAKE) -C $(patsubst prepare-%,%,$@) \
		-f $(SCRIPTS_DIR)/$(patsubst prepare-%,%,$@)/prepare.mk

.PHONY: $(addprefix build-, $(SUBPROJECTS))
$(addprefix build-, $(SUBPROJECTS)): prepare
	+$(MAKE) -f $(SCRIPTS_DIR)/$(patsubst build-%,%,$@)/build.outer.mk
