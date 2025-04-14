HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/../here.mk
include $(SCRIPTS_DIR)/shared.mk

.PHONY: all bootstrap
all: bootstrap
bootstrap: configure

configure:
	./bootstrap
