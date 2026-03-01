#!/usr/bin/env bash
# Drifting Bubble OS - Productivity Snap Downloader
# Downloads popular productivity snaps (plus assertions) into /shared/snaps.
#
# Usage: sudo bash scripts/download_productivity_snaps.sh
#
# Environment variables:
#   SNAP_DOWNLOAD_DIR - destination directory for downloaded .snap/.assert files
#                       (default: /shared/snaps)

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

if ! command -v snap &>/dev/null; then
    echo "Error: snap command not found. Install snapd first." >&2
    exit 1
fi

SNAP_DOWNLOAD_DIR="${SNAP_DOWNLOAD_DIR:-/shared/snaps}"
mkdir -p "${SNAP_DOWNLOAD_DIR}"

download_productivity_app() {
    local app_slug="$1"
    local channel="$2"
    local classic_flag="$3"
    shift 3
    local candidates=("$@")

    local tmpdir
    tmpdir="$(mktemp -d)"
    local downloaded=0

    for snap_name in "${candidates[@]}"; do
        local cmd=(snap download "${snap_name}")

        if [[ -n "${channel}" ]]; then
            cmd+=(--channel "${channel}")
        fi

        if [[ "${classic_flag}" == "yes" ]]; then
            cmd+=(--classic)
        fi

        echo "[snap] ${app_slug} -> trying '${snap_name}'"
        if (
            cd "${tmpdir}"
            "${cmd[@]}"
        ); then
            downloaded=1
            break
        fi
    done

    if [[ ${downloaded} -eq 0 ]]; then
        echo "[snap] ${app_slug} unavailable; skipping."
        rm -rf "${tmpdir}"
        return 1
    fi

    local found_any=0
    for artifact in "${tmpdir}"/*.snap "${tmpdir}"/*.assert; do
        if [[ -e "${artifact}" ]]; then
            found_any=1
            local artifact_name
            artifact_name="$(basename "${artifact}")"
            local destination="${SNAP_DOWNLOAD_DIR}/productivity-${app_slug}-${artifact_name}"
            mv "${artifact}" "${destination}"
            echo "[snap] saved ${destination}"
        fi
    done

    rm -rf "${tmpdir}"

    if [[ ${found_any} -eq 0 ]]; then
        echo "[snap] ${app_slug} produced no artifacts; skipping."
        return 1
    fi

    return 0
}

echo "--- Productivity snap download destination: ${SNAP_DOWNLOAD_DIR} ---"

# Popular free productivity choices with fallback names where practical
download_productivity_app "libreoffice" "" "no" "libreoffice" || true
download_productivity_app "onlyoffice" "" "no" "onlyoffice-desktopeditors" "onlyoffice" || true
download_productivity_app "thunderbird" "" "no" "thunderbird" || true
download_productivity_app "joplin" "" "no" "joplin-desktop" "joplin-james-carroll" || true
download_productivity_app "obsidian" "" "yes" "obsidian" || true
download_productivity_app "xournalpp" "" "no" "xournalpp" || true
download_productivity_app "drawio" "" "no" "drawio" "draw-io" || true
download_productivity_app "simplenote" "" "no" "simplenote" || true
download_productivity_app "standard-notes" "" "no" "standard-notes" "standardnotes" || true
download_productivity_app "calibre" "" "no" "calibre" || true

echo ""
echo "=== Productivity snap download complete ==="
echo "Files saved in: ${SNAP_DOWNLOAD_DIR}"
