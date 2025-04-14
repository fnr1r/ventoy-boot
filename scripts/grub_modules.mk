NET_MODULES_LEGACY := http net tftp
NET_MODULES_UEFI   := $(NET_MODULES_LEGACY) efinet

MOD_COMPR := gzio lzopio xzio
MOD_FS    := exfat ext2 fat iso9660 ntfs udf xfs
MOD_GFX   := gfxmenu gfxterm gfxterm_background gfxterm_menu
MOD_HASH  := gcry_md5 hashsum password_pbkdf2
MOD_IMG   := jpeg png
MOD_LNX   := linux newc squash4
MOD_PART  := part_gpt part_msdos
MOD_VIDEO := all_video video video_colors video_fb

MODULES_SHARED := $(MOD_COMPR) $(MOD_FS) $(MOD_GFX) $(MOD_HASH) $(MOD_IMG) \
	$(MOD_LNX) $(MOD_PART) $(MOD_VIDEO) \
	blocklist boot chain configfile echo extcmd file font gettext halt \
	loopback ls minicmd normal read reboot search sleep tar terminal test trig \
	true ventoy

MODULES_LEGACY_SHARED := biosdisk drivemap linux16 lspci ntldr pci vbe vga \
	vga_text videoinfo videotest videotest_checksum
MODULES_UEFI_SHARED   := acpi bitmap bitmap_scale bufio cat crypto datetime \
	diskfilter efifwsetup efi_gop fshelp gcry_sha512 hfsplus mmap part_apple \
	pbkdf2 priority_queue regexp serial setkey terminfo zfs

MODULES_X86_DRIVERS := at_keyboard usb_keyboard video_bochs video_cirrus smbios

ALL_MODULES_X86_LEGACY := $(MODULES_SHARED) $(MODULES_LEGACY_SHARED) $(MODULES_X86_DRIVERS)
ALL_MODULES_X86_UEFI   := $(MODULES_SHARED) $(MODULES_UEFI_SHARED)   $(MODULES_X86_DRIVERS)
ALL_MODULES_RISC       := $(MODULES_SHARED) $(MODULES_UEFI_SHARED)
