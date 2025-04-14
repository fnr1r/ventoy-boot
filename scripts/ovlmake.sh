#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$(readlink -f -- "$0")")"

. "$HERE/../repo.sh"

MAKEBIN=()

exit_on_dry_run() {
    for arg in "$@"; do
        if [ "$arg" == "-n" ]; then
            exit 69
        fi
    done
}

main() {
    local format="$1"
    shift
    exit_on_dry_run "$@"
    if [ $# -eq 0 ]; then
        MAKEBIN=(make)
    else
        MAKEBIN=("$@")
    fi

    MAKEFILE="$HERE/$format.mk"
    ENVEXTRA=()
    if [ "$format" != "bootstrap" ]; then
        MAKEFILE="$HERE/build.mk"
        ENVEXTRA=("FORMAT=$format")
    fi

    exec env STAGENAME="$format" "${ENVEXTRA[@]}" bash "$REPO_DIR/scripts/run_in_overlay.sh" \
        "${MAKEBIN[@]}" -f "$MAKEFILE"
}

_entry() {
    set -euo pipefail
    main "$@"
    eval "exit 0"
}

_entry "$@"
