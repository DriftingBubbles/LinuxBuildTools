#!/usr/bin/env bash
# Drifting Bubble OS - Kiwix Torrent Downloader
# Discovers Kiwix .zim files and downloads matching .zim.torrent files.
#
# Usage: bash scripts/download_kiwix_torrents.sh
#
# Environment variables:
#   KIWIX_TORRENT_DIR - destination directory for torrent files
#                       (default: /share/torrent/zim)

set -euo pipefail

KIWIX_TORRENT_DIR="${KIWIX_TORRENT_DIR:-/share/torrent/zim}"
KIWIX_RSYNC_SOURCE="rsync://download.kiwix.org/zim/"
KIWIX_HTTP_SOURCE="https://download.kiwix.org/zim/"

mkdir -p "${KIWIX_TORRENT_DIR}"

download_file() {
    local source_url="$1"
    local destination_file="$2"

    mkdir -p "$(dirname "${destination_file}")"

    if command -v wget &>/dev/null; then
        wget -q --show-progress -O "${destination_file}" "${source_url}"
        return 0
    fi

    if command -v curl &>/dev/null; then
        curl -fsSL "${source_url}" -o "${destination_file}"
        return 0
    fi

    echo "Error: neither wget nor curl is available for downloading files." >&2
    return 1
}

discover_zim_paths_rsync() {
    local output_file="$1"
    if ! command -v rsync &>/dev/null; then
        return 1
    fi

    echo "--- Discovering .zim files with rsync listing ---"
    rsync -r --list-only \
        --include='*/' \
        --include='*.zim' \
        --exclude='*' \
        "${KIWIX_RSYNC_SOURCE}" \
        | awk '/\.zim$/ { print $NF }' \
        | sort -u > "${output_file}"

    [[ -s "${output_file}" ]]
}

discover_zim_paths_wget() {
    local output_file="$1"
    if ! command -v wget &>/dev/null; then
        return 1
    fi

    echo "--- rsync unavailable/failed; discovering .zim files with wget spider ---"
    wget \
        --spider \
        --recursive \
        --no-parent \
        --accept='*.zim' \
        --execute robots=off \
        "${KIWIX_HTTP_SOURCE}" 2>&1 \
        | grep -Eo 'https?://[^ ]+\.zim' \
        | sed "s#^${KIWIX_HTTP_SOURCE}##" \
        | sort -u > "${output_file}"

    [[ -s "${output_file}" ]]
}

echo "--- Destination: ${KIWIX_TORRENT_DIR} ---"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

zim_list_file="${tmpdir}/zim_paths.txt"

if ! discover_zim_paths_rsync "${zim_list_file}"; then
    if ! discover_zim_paths_wget "${zim_list_file}"; then
        echo "Error: could not discover .zim files from Kiwix sources." >&2
        exit 1
    fi
fi

echo "--- Downloading matching .zim.torrent files ---"

total_count=0
downloaded_count=0
failed_count=0

while IFS= read -r zim_rel_path; do
    [[ -z "${zim_rel_path}" ]] && continue

    total_count=$((total_count + 1))
    torrent_rel_path="${zim_rel_path}.torrent"
    torrent_url="${KIWIX_HTTP_SOURCE}${torrent_rel_path}"
    destination_file="${KIWIX_TORRENT_DIR}/${torrent_rel_path}"

    if download_file "${torrent_url}" "${destination_file}"; then
        downloaded_count=$((downloaded_count + 1))
    else
        failed_count=$((failed_count + 1))
        rm -f "${destination_file}" || true
        echo "Warning: failed to download ${torrent_rel_path}" >&2
    fi
done < "${zim_list_file}"

torrent_count="$(find "${KIWIX_TORRENT_DIR}" -type f -name '*.torrent' | wc -l | tr -d '[:space:]')"

echo ""
echo "=== Kiwix torrent download complete ==="
echo "Discovered .zim files: ${total_count}"
echo "Downloaded torrents this run: ${downloaded_count}"
echo "Failed downloads this run: ${failed_count}"
echo "Stored torrent files: ${torrent_count}"
echo "Location: ${KIWIX_TORRENT_DIR}"
