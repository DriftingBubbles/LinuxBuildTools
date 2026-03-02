#!/usr/bin/env bash
# Drifting Bubble OS - Emulator Snap Downloader
# Downloads popular emulator snaps (plus assertions) into /shared/snaps.
#
# ROM sourcing note:
# - Use only properly licensed, homebrew, or public domain ROM files.
# - Helpful sources include:
#   - https://pdroms.de/
#   - https://www.scummvm.org/games/
#   - https://archive.org/details/softwarelibrary (license varies by item)
# - Always verify each file's license and your local redistribution laws.
#
# Usage: sudo bash scripts/download_emulator_snaps.sh
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

print_rom_sourcing_note() {
    echo ""
    echo "=== ROM sourcing note ==="
    echo "Use only properly licensed, homebrew, or public domain ROM files."
    echo "Helpful sources:"
    echo "- https://pdroms.de/"
    echo "- https://www.scummvm.org/games/"
    echo "- https://archive.org/details/softwarelibrary (license varies by item)"
    echo "Always verify file licenses and local redistribution laws."
    echo ""
}

download_emulator() {
    local emu_slug="$1"
    local channel="$2"
    shift 2
    local candidates=("$@")

    local tmpdir
    tmpdir="$(mktemp -d)"
    local downloaded=0

    for snap_name in "${candidates[@]}"; do
        local cmd=(snap download "${snap_name}")
        if [[ -n "${channel}" ]]; then
            cmd+=(--channel "${channel}")
        fi

        echo "[snap] ${emu_slug} -> trying '${snap_name}'"
        if (
            cd "${tmpdir}"
            "${cmd[@]}"
        ); then
            downloaded=1
            break
        fi
    done

    if [[ ${downloaded} -eq 0 ]]; then
        echo "[snap] ${emu_slug} unavailable; skipping."
        rm -rf "${tmpdir}"
        return 1
    fi

    local found_any=0
    for artifact in "${tmpdir}"/*.snap "${tmpdir}"/*.assert; do
        if [[ -e "${artifact}" ]]; then
            found_any=1
            local artifact_name
            artifact_name="$(basename "${artifact}")"
            local destination="${SNAP_DOWNLOAD_DIR}/emulator-${emu_slug}-${artifact_name}"
            mv "${artifact}" "${destination}"
            echo "[snap] saved ${destination}"
        fi
    done

    rm -rf "${tmpdir}"

    if [[ ${found_any} -eq 0 ]]; then
        echo "[snap] ${emu_slug} produced no artifacts; skipping."
        return 1
    fi

    return 0
}

echo "--- Emulator snap download destination: ${SNAP_DOWNLOAD_DIR} ---"
print_rom_sourcing_note

# Popular emulator choices with fallback snap names
download_emulator "retroarch" "" "retroarch" || true
download_emulator "ppsspp" "" "ppsspp-emu" "ppsspp" || true
download_emulator "dolphin" "" "dolphin-emu" "dolphin-emulator" || true
download_emulator "duckstation" "" "duckstation" || true
download_emulator "pcsx2" "" "pcsx2" || true
download_emulator "mupen64plus" "" "mupen64plus" "mupen64plus-qt" || true
download_emulator "dosbox" "" "dosbox-x" "dosbox" || true
download_emulator "scummvm" "" "scummvm" || true

echo ""
echo "=== Emulator snap download complete ==="
echo "Files saved in: ${SNAP_DOWNLOAD_DIR}"
