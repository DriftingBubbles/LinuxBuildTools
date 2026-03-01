#!/usr/bin/env bash
# Drifting Bubble OS - Main Installation Script
# Orchestrates APT packages, snap installs, and file share setup.
#
# Usage: sudo bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

echo "========================================"
echo "   Drifting Bubble OS - Build Tools"
echo "========================================"
echo ""

bash "${SCRIPT_DIR}/scripts/install_apt_packages.sh"
echo ""

bash "${SCRIPT_DIR}/scripts/install_language_support.sh"
echo ""

bash "${SCRIPT_DIR}/scripts/install_snaps.sh"
echo ""

bash "${SCRIPT_DIR}/scripts/download_utility_snaps.sh"
echo ""

bash "${SCRIPT_DIR}/scripts/download_entertainment_snaps.sh"
echo ""

bash "${SCRIPT_DIR}/scripts/download_emulator_snaps.sh"
echo ""

bash "${SCRIPT_DIR}/scripts/download_server_snaps.sh"
echo ""

bash "${SCRIPT_DIR}/scripts/download_productivity_snaps.sh"
echo ""

bash "${SCRIPT_DIR}/scripts/setup_fileshare.sh"
echo ""

echo "========================================"
echo "   Installation complete!"
echo "   Run ./menu.sh to manage your system."
echo "========================================"
