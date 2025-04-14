#!/usr/bin/env bash

FORMATS=(
    i386-pc i386-efi x86_64-efi
    aarch64-efi mips64el-efi
)
export FORMATS

get_boot_file_name() {
    IFS=- read -r target platform <<< "$1"
    if [[ "$platform" != "efi" ]] && [[ "$platform" != "" ]]; then
        exit 1
    fi
    case "$target" in
        i386)
            echo "BOOTIA32.EFI"
            #if [[ "$2" == "signed" ]]; then
            #fi
            #echo "grubia32_real.efi"
        ;;
        x86_64)
            echo "BOOTX64.EFI"
            #if [[ "$2" == "signed" ]]; then
            #fi
            #echo "grubx64_real.efi"
        ;;
        aarch64|arm64)
            echo "BOOTAA64.EFI"
            ;;
        mips64el)
            echo "BOOTMIPS.EFI"
            ;;
        *)
            exit 1
        ;;
    esac
}

get_boot_file_path() {
    name="$(get_boot_file_name "$@")"
    echo "EFI/BOOT/$name"
}

if ! (return 0 2> /dev/null); then
    set -euo pipefail
    "$@"
    eval "exit 0"
fi
