#!/usr/bin/env bash
set -euo pipefail

main() {
    if [ -z "${EDK2_MODULES:-}" ]; then
        exit 69
    fi
    exprpaths=""
    for mod in $EDK2_MODULES; do
        exprpaths+="\\n  MdeModulePkg/Application/$mod/$mod.inf"
    done
    expression="s|\\[Components\\]|[Components]$exprpaths|"

    sed -e "$expression" -i "MdeModulePkg/MdeModulePkg.dsc"
}

_entry() {
    set -euo pipefail
    main "$@"
    eval "exit 0"
}

_entry "$@"
