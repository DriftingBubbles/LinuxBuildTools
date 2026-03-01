#!/usr/bin/env bash
# Drifting Bubble OS - Entertainment Snap Downloader
# Downloads popular free game/entertainment snaps into /shared/snaps.
#
# Categories included:
# - Arcade style
# - Board game style
# - Go
# - Reversi
# - Solitaire
# - Card game style
#
# Usage: sudo bash scripts/download_entertainment_snaps.sh
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

download_game() {
    local category_slug="$1"
    local game_slug="$2"
    shift 2
    local candidates=("$@")

    local tmpdir
    tmpdir="$(mktemp -d)"
    local downloaded=0

    echo "[snap] ${category_slug}: ${game_slug}"

    for snap_name in "${candidates[@]}"; do
        echo "[snap] trying '${snap_name}'"
        if (
            cd "${tmpdir}"
            snap download "${snap_name}"
        ); then
            downloaded=1
            break
        fi
    done

    if [[ ${downloaded} -eq 0 ]]; then
        echo "[snap] ${game_slug} unavailable on this system/channel; skipping."
        rm -rf "${tmpdir}"
        return 1
    fi

    local found_any=0
    for artifact in "${tmpdir}"/*.snap "${tmpdir}"/*.assert; do
        if [[ -e "${artifact}" ]]; then
            found_any=1
            local artifact_name
            artifact_name="$(basename "${artifact}")"
            local destination="${SNAP_DOWNLOAD_DIR}/${category_slug}-${game_slug}-${artifact_name}"
            mv "${artifact}" "${destination}"
            echo "[snap] saved ${destination}"
        fi
    done

    rm -rf "${tmpdir}"

    if [[ ${found_any} -eq 0 ]]; then
        echo "[snap] ${game_slug} produced no artifacts; skipping."
        return 1
    fi

    return 0
}

echo "--- Entertainment snap download destination: ${SNAP_DOWNLOAD_DIR} ---"

echo ""
echo "--- Arcade style ---"
download_game "arcade" "supertuxkart" "supertuxkart" || true

echo ""
echo "--- Board game style ---"
download_game "board" "gnome-chess" "gnome-chess" "chess" || true

echo ""
echo "--- Go ---"
download_game "go" "go-game" "gnugo" "q5go" "sabaki" || true

echo ""
echo "--- Reversi ---"
download_game "reversi" "reversi-game" "iagno" "reversi" || true

echo ""
echo "--- Solitaire ---"
download_game "solitaire" "aisleriot" "aisleriot" "solitaire" || true

echo ""
echo "--- Card game style ---"
download_game "card" "pysolfc" "pysolfc" "pysol" || true

echo ""
echo "=== Entertainment snap download complete ==="
echo "Files saved in: ${SNAP_DOWNLOAD_DIR}"
