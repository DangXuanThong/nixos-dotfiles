#!/usr/bin/env bash

set -Eeuo pipefail
trap 'echo "ERROR: $BASH_COMMAND (line $LINENO)"' ERR

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="${1:-${SCRIPT_DIR}/../src/MacTahoeXCursor}"
DEST_DIR="${2:-${HOME}/.icons/MacTahoeCursor}"

main() {
    cd "$SRC_DIR/cursors"
    mkdir -p "$DEST_DIR/cursors"

    for dir in */; do
        cursor="${dir%/}"
        if [ -f "$cursor/$cursor.in" ]; then
            echo "Building: $cursor"
            (cd "$cursor" && xcursorgen "$cursor.in" "$DEST_DIR/cursors/$cursor")
        fi
    done

    cp "$SRC_DIR/index.theme" "$DEST_DIR/"
}

main "$@"
