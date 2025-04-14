#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$(readlink -f -- "$0")")"

. "$HERE/../../repo.sh"

main() {
    SOURCE="$1"
    TARGET="$REPO_DIR/dist/grub/$2"
    if [[ -d "$TARGET" ]]; then
        rm -r "$TARGET"
    fi
    mkdir -p "$TARGET"
    cp -a "$SOURCE"/*.lst "$SOURCE"/*.mod "$TARGET"/
    eval "exit 0"
}

main "$@"
