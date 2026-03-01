#!/usr/bin/env bash
# Drifting Bubble OS - Utility Snap Downloader
# Downloads selected utility snaps (plus assertions) for English, Spanish,
# and French locale contexts into /shared/snaps.
#
# Usage: sudo bash scripts/download_utility_snaps.sh
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

download_for_locale() {
    local app_slug="$1"
    local locale_name="$2"
    local locale_tag="$3"
    local channel="$4"
    local classic_flag="$5"
    shift 5

    local tmpdir
    tmpdir="$(mktemp -d)"
    local downloaded=0

    for snap_name in "$@"; do
        local cmd=(snap download "${snap_name}")

        if [[ -n "${channel}" ]]; then
            cmd+=(--channel "${channel}")
        fi

        if [[ "${classic_flag}" == "yes" ]]; then
            cmd+=(--classic)
        fi

        echo "[snap] ${app_slug} (${locale_tag}) -> trying '${snap_name}'"
        if (
            cd "${tmpdir}"
            LANG="${locale_name}" LANGUAGE="${locale_name}" LC_ALL="${locale_name}" "${cmd[@]}"
        ); then
            downloaded=1
            break
        fi
    done

    if [[ ${downloaded} -eq 0 ]]; then
        echo "[snap] ${app_slug} (${locale_tag}) -> not found or failed; skipping."
        rm -rf "${tmpdir}"
        return 1
    fi

    local found_any=0
    for artifact in "${tmpdir}"/*.snap "${tmpdir}"/*.assert; do
        if [[ -e "${artifact}" ]]; then
            found_any=1
            local artifact_name
            artifact_name="$(basename "${artifact}")"
            local destination="${SNAP_DOWNLOAD_DIR}/${app_slug}-${locale_tag}-${artifact_name}"
            mv "${artifact}" "${destination}"
            echo "[snap] saved ${destination}"
        fi
    done

    rm -rf "${tmpdir}"

    if [[ ${found_any} -eq 0 ]]; then
        echo "[snap] ${app_slug} (${locale_tag}) -> no artifacts produced; skipping."
        return 1
    fi

    return 0
}

download_app() {
    local app_slug="$1"
    local channel="$2"
    local classic_flag="$3"
    shift 3
    local candidates=("$@")

    echo ""
    echo "--- Downloading '${app_slug}' for English / Spanish / French ---"

    download_for_locale "${app_slug}" "en_US.UTF-8" "en" "${channel}" "${classic_flag}" "${candidates[@]}" || true
    download_for_locale "${app_slug}" "es_ES.UTF-8" "es" "${channel}" "${classic_flag}" "${candidates[@]}" || true
    download_for_locale "${app_slug}" "fr_FR.UTF-8" "fr" "${channel}" "${classic_flag}" "${candidates[@]}" || true
}

echo "--- Snap download destination: ${SNAP_DOWNLOAD_DIR} ---"

# Requested utility snaps (with practical fallback names where needed)
download_app "kiwix" "" "no" "kiwix" "kiwix-desktop"
download_app "ffmpeg2" "" "no" "ffmpeg2" "ffmpeg" "ffmpeg-2204"
download_app "vlc-player" "" "no" "vlc"
download_app "firefox" "" "no" "firefox"
download_app "opera" "" "no" "opera"
download_app "chromium" "" "no" "chromium"
download_app "plex" "" "yes" "plex" "plexmediaserver"
download_app "postgres" "" "no" "postgres" "postgresql10" "postgresql14"
download_app "pgadmin4" "" "no" "pgadmin4"
download_app "visual-studio-code" "" "yes" "code"
download_app "dolphin-file-manager" "" "no" "dolphin"
download_app "krita" "" "no" "krita"
download_app "gimp" "" "no" "gimp"
download_app "inkscape" "" "no" "inkscape"

echo ""
echo "=== Utility snap download complete ==="
echo "Files saved in: ${SNAP_DOWNLOAD_DIR}"
