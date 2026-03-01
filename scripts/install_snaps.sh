#!/usr/bin/env bash
# Drifting Bubble OS - Snap Package Installer
# Downloads snap packages to SNAP_STORE_DIR (for offline reuse) and installs them.
#
# Usage: sudo bash scripts/install_snaps.sh
#
# Environment variables:
#   SNAP_STORE_DIR  – directory where .snap files are cached
#                     (default: /opt/drifting-bubble/snaps)

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

SNAP_STORE_DIR="${SNAP_STORE_DIR:-/opt/drifting-bubble/snaps}"
mkdir -p "${SNAP_STORE_DIR}"

# ---------------------------------------------------------------------------
# Helper: install a snap and cache it to SNAP_STORE_DIR
#   $1 – snap name
#   $2 – optional extra flags, e.g. "--classic"
# ---------------------------------------------------------------------------
install_snap() {
    local name="$1"
    local flags="${2:-}"
    local snap_file="${SNAP_STORE_DIR}/${name}.snap"

    if snap list "${name}" &>/dev/null; then
        echo "[snap] ${name} is already installed – skipping."
        return
    fi

    # Use a cached .snap file if available (offline mode)
    if [[ -f "${snap_file}" ]]; then
        echo "[snap] Installing ${name} from cached file ${snap_file} ..."
        # shellcheck disable=SC2086
        snap install ${flags} --dangerous "${snap_file}"
    else
        echo "[snap] Downloading and installing ${name} ..."
        # shellcheck disable=SC2086
        snap install ${flags} "${name}"

        # Cache the installed snap for later offline reuse
        local installed_snap
        installed_snap="$(find /var/lib/snapd/snaps -maxdepth 1 \
            -name "${name}_*.snap" 2>/dev/null | sort -V | tail -1)"
        if [[ -n "${installed_snap}" ]]; then
            cp "${installed_snap}" "${snap_file}"
            echo "[snap] Cached ${name} to ${snap_file}"
        fi
    fi
}

echo "--- Snap store directory: ${SNAP_STORE_DIR} ---"
echo ""

# ---------------------------------------------------------------------------
# Kiwix Desktop – offline Wikipedia / knowledge base reader
# ---------------------------------------------------------------------------
echo "--- Installing kiwix-desktop ---"
install_snap "kiwix-desktop"

# ---------------------------------------------------------------------------
# Plex Media Server – local media streaming
# ---------------------------------------------------------------------------
echo "--- Installing plexmediaserver ---"
install_snap "plexmediaserver" "--classic"

# ---------------------------------------------------------------------------
# Torrent client (snap alternative to qbittorrent-nox)
# ---------------------------------------------------------------------------
echo "--- Installing transmission (torrent) ---"
install_snap "transmission"

# ---------------------------------------------------------------------------
# Signal Desktop – encrypted messaging / light communication
# ---------------------------------------------------------------------------
echo "--- Installing signal-desktop ---"
install_snap "signal-desktop" "--classic"

echo ""
echo "=== Snap installation complete ==="
echo "Cached snap files are in: ${SNAP_STORE_DIR}"
