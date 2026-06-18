#!/usr/bin/env bash

set -Eeuo pipefail
trap 'echo "ERROR: $BASH_COMMAND (line $LINENO)"' ERR

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="${1:-${SCRIPT_DIR}/../src/MacTahoeCursor}"
DEST_DIR="${2:-${HOME}/.icons}"

main() {
    echo "Building MacTahoeCursor theme at ${SRC_DIR} using hyprcursor..."
    rm -rf "${DEST_DIR}/theme_MacOS Tahoe Cursor" "${DEST_DIR}/MacTahoeCursor"
    mkdir -p "${DEST_DIR}"
    hyprcursor-util --create "${SRC_DIR}" --output "${DEST_DIR}"
    mv "${DEST_DIR}/theme_MacOS Tahoe Cursor" "${DEST_DIR}/MacTahoeCursor"
    echo "MacTahoeCursor theme has been built and installed to ${DEST_DIR}/MacTahoeCursor"
}

main "$@"
