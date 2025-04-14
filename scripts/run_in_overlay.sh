#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$(readlink -f -- "$0")")"

. "$HERE/../repo.sh"

SHARED_OVERLAY_DIR="$REPO_DIR/build-overlay"
SHARED_WORK_DIR="$REPO_DIR/build-work"
SRC_DIR="$REPO_DIR/src"

err() {
    echo "$@"
    exit 1
}

mount_overlay() {
    sudo mount -t overlay overlay "$@"
}

OVL_LOWER_DIRS=()
OVL_UPPER_DIR=""
OVL_WORK_DIR=""
OVL_MOUNTPOINT_DIR=""
OVL_MOUNTED=0

umount_hook() {
    if [ "$OVL_MOUNTED" = 0 ]; then
        return
    fi
    popd > /dev/null
    while ! sudo umount "$OVL_MOUNTPOINT_DIR"; do
        sleep 0.1
    done
    OVL_MOUNTED=0
    trap - EXIT
}

ovl_env_lower() {
    if [ -z "${LOWERDIRS:-}" ]; then
        return
    fi
    IFS=':'
    for low in $LOWERDIRS; do
        local path="$SHARED_OVERLAY_DIR/$low/upper"
        if ! [ -d "$path" ]; then
            err "\"$path\" does not exist"
        fi
        OVL_LOWER_DIRS+=("$path")
    done
}

ovl_env_upper() {
    if [ -z "${UPPERDIR:-}" ]; then
        err "UPPERDIR is undefined"
    fi
    OVL_UPPER_DIR="$SHARED_OVERLAY_DIR/$UPPERDIR/upper"
    OVL_WORK_DIR="$SHARED_OVERLAY_DIR/$UPPERDIR/work"
    OVL_MOUNTPOINT_DIR="$SHARED_WORK_DIR/$UPPERDIR"
    mkdir -p "$OVL_UPPER_DIR" "$OVL_WORK_DIR" "$OVL_MOUNTPOINT_DIR"
}

opts_sanity_check() {
    semicolon_count="$(echo -n "$1" | grep -o "," | wc -l)"
    if [ "$semicolon_count" -eq 2 ]; then
        return
    fi
    echo "$1" > /dev/stderr
    err "opt flag sanity check failed"
}

ovl_setup() {
    local lowerdirs="$SRC_DIR"
    for low in "${OVL_LOWER_DIRS[@]}"; do
        lowerdirs="$low:$lowerdirs"
    done
    local upperdir="$OVL_UPPER_DIR"
    local workdir="$OVL_WORK_DIR"
    local mountpoint="$OVL_MOUNTPOINT_DIR"
    local opts="lowerdir=$lowerdirs,upperdir=$upperdir,workdir=$workdir"
    opts_sanity_check "$opts"
    mount_overlay "$mountpoint" -o "$opts"
    OVL_MOUNTED=1
    trap umount_hook EXIT
}

main() {
    ovl_env_lower
    ovl_env_upper
    ovl_setup
    pushd "$OVL_MOUNTPOINT_DIR" > /dev/null
    "$@"
    umount_hook
}

_entry() {
    set -euo pipefail
    main "$@"
    eval "exit 0"
}

_entry "$@"
