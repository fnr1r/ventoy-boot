#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$(readlink -f -- "$0")")"

TMP_DOWNLOAD="/tmp/toolchains_download"

TOOLCHAINS=(
    "https://github.com/ventoy/vtoytoolchain/releases/download/1.0/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu.tar.xz#gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu#gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu"
    "https://github.com/ventoy/vtoytoolchain/releases/download/1.0/mips-loongson-gcc7.3-2019.06-29-linux-gnu.tar.gz#mips-loongson-gcc7.3-linux-gnu/2019.06-29#mips-loongson-gcc7.3-2019.06-29-linux-gnu"
)

download_and_extract() {
    url="$1"
    src="$2"
    dest="$3"
    url_file="$(basename "$url")"

    echo "$url"

    if ! [[ -f "$url_file" ]]; then
        echo "  downloading"
        wget -q "$url" -O "$url_file"
    else
        echo "  skipping download"
    fi

    if ! [[ -f "$url_file.skip_check" ]]; then
        printf "  verifying: "
        sha256sum -c "$url_file.sha256"
    else
        echo "  skipping verification"
    fi

    tmpd="$(mktemp -d)"
    pushd "$tmpd" > /dev/null
    echo "  extracting"
    tar xf "$TMP_DOWNLOAD/$url_file"
    mv "$src" "$dest"
    echo "  done"
    popd > /dev/null
    rm -r "$tmpd"
}

main() {
    cd "$HERE"
    mkdir -p "$TMP_DOWNLOAD"
    cp -a --reflink=auto . "$TMP_DOWNLOAD"
    cd "$TMP_DOWNLOAD"
    for i in "${TOOLCHAINS[@]}"; do
        IFS='#' read -r url src dest <<< "$i"
        download_and_extract "$url" "$src" "/opt/$dest"
    done
    rm -r "$TMP_DOWNLOAD"
}

_entry() {
    set -euo pipefail
    main "$@"
    eval "exit 0"
}

_entry "$@"
