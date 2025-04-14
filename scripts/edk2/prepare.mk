HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk
include $(HERE)/info.mk

EDK_MOD_LINKS := $(addprefix MdeModulePkg/Application/, $(EDK2_MODULES))

.PHONY: all prepare
all: prepare
prepare: add_ventoy build_tools first_source

.PHONY: add_ventoy build_tools first_source
add_ventoy: $(BUILDINFO_DIR)/dscpatch $(EDK_MOD_LINKS)
build_tools:
	+$(MAKE) -C BaseTools/Source/C

MdeModulePkg/Application/%: ../edk2_modules/%
	ln -sf ../../$< $@

$(BUILDINFO_DIR)/dscpatch:
	env EDK2_MODULES="$(EDK2_MODULES)" bash $(SCRIPTS_DIR)/edk2/sedcmd.sh
	@mkdir -p $(dir $@)
	@touch $@
