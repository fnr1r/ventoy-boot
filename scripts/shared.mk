lowercase = $(shell echo "$1" | tr '[:upper:]' '[:lower:]')
uppercase = $(shell echo "$1" | tr '[:lower:]' '[:upper:]')

CP_FILE := cp -a --reflink=auto
CP_DIR := cp -ar --reflink=auto

EDK2_ARCHES := x64 ia32 aarch64
GRUB_FORMATS := i386-pc i386-efi x86_64-efi aarch64-efi mips64el-efi
IPXE_ARCHES := i386
