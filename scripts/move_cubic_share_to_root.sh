#!/usr/bin/env bash
# Drifting Bubble OS - Move Cubic Share Content Into Root Environment
# Moves prepared host content from /shared/cubic/source/* into the Cubic
# root environment share directory.
#
# Usage:
#   sudo bash scripts/move_cubic_share_to_root.sh
#
# Environment variables:
#   HOST_CUBIC_SOURCE_ROOT  Host source root (default: /shared/cubic/source)
#   CUBIC_ROOT              Cubic root filesystem path (default: /)
#
# Special instruction:
# - If running this OUTSIDE the Cubic shell/chroot, set CUBIC_ROOT to the
#   extracted Cubic rootfs path (example: /path/to/cubic-project/custom-root).

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

HOST_CUBIC_SOURCE_ROOT="${HOST_CUBIC_SOURCE_ROOT:-/shared/cubic/source}"
CUBIC_ROOT="${CUBIC_ROOT:-/}"

if [[ ! -d "${HOST_CUBIC_SOURCE_ROOT}" ]]; then
    echo "Error: host source root not found: ${HOST_CUBIC_SOURCE_ROOT}" >&2
    exit 1
fi

if ! getent group users >/dev/null 2>&1; then
    echo "Error: required group 'users' was not found on this system." >&2
    exit 1
fi

normalize_root() {
    local root_path="$1"
    if [[ "${root_path}" == "/" ]]; then
        echo "/"
    else
        echo "${root_path%/}"
    fi
}

ROOT_PATH="$(normalize_root "${CUBIC_ROOT}")"

if [[ "${ROOT_PATH}" == "/" ]]; then
    CUBIC_SHARE_DIR="/shared"
else
    CUBIC_SHARE_DIR="${ROOT_PATH}/shared"
fi

mkdir -p "${CUBIC_SHARE_DIR}/media" "${CUBIC_SHARE_DIR}/zim" "${CUBIC_SHARE_DIR}/torrents" "${CUBIC_SHARE_DIR}/installers"

move_from_source_dir() {
    local source_dir="$1"
    local dest_dir="$2"

    if [[ ! -d "${source_dir}" ]]; then
        echo "[move] source not found, skipping: ${source_dir}"
        return 0
    fi

    shopt -s dotglob nullglob
    local items=("${source_dir}"/*)
    shopt -u dotglob nullglob

    if [[ ${#items[@]} -eq 0 ]]; then
        echo "[move] no files to move from: ${source_dir}"
        return 0
    fi

    echo "[move] ${source_dir} -> ${dest_dir}"
    mkdir -p "${dest_dir}"

    local item
    for item in "${items[@]}"; do
        mv "${item}" "${dest_dir}/"
    done
}

move_from_source_dir "${HOST_CUBIC_SOURCE_ROOT}/media" "${CUBIC_SHARE_DIR}/media"
move_from_source_dir "${HOST_CUBIC_SOURCE_ROOT}/zim" "${CUBIC_SHARE_DIR}/zim"
move_from_source_dir "${HOST_CUBIC_SOURCE_ROOT}/torrents" "${CUBIC_SHARE_DIR}/torrents"
move_from_source_dir "${HOST_CUBIC_SOURCE_ROOT}/installers" "${CUBIC_SHARE_DIR}/installers"

chown -R root:users "${CUBIC_SHARE_DIR}"

echo ""
echo "=== Cubic share transfer complete ==="
echo "Source root: ${HOST_CUBIC_SOURCE_ROOT}"
echo "Cubic share: ${CUBIC_SHARE_DIR}"
echo "Ownership set: root:users"
