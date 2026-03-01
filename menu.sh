#!/usr/bin/env bash
# Drifting Bubble OS - System Management Menu
# Shows snap packages available in the local snap store directory and
# whether each one is currently installed on the system.
#
# Usage: bash menu.sh   (root not required for viewing; root needed to install)
#
# Environment variables:
#   SNAP_STORE_DIR  – directory containing cached .snap files
#                     (default: /opt/drifting-bubble/snaps)

set -euo pipefail

SNAP_STORE_DIR="${SNAP_STORE_DIR:-/opt/drifting-bubble/snaps}"

# ---------------------------------------------------------------------------
# Colour helpers
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Helper: check whether a snap is installed
#   $1 – snap name (without .snap extension)
# Returns 0 if installed, 1 otherwise
# ---------------------------------------------------------------------------
is_snap_installed() {
    snap list "$1" &>/dev/null
}

# ---------------------------------------------------------------------------
# Helper: derive a human-friendly display name from a snap filename
#   e.g. "kiwix-desktop.snap" -> "kiwix-desktop"
# ---------------------------------------------------------------------------
snap_display_name() {
    basename "$1" .snap
}

# ---------------------------------------------------------------------------
# Display the snap status table
# ---------------------------------------------------------------------------
show_snap_status() {
    echo ""
    echo -e "${BOLD}${CYAN}=== Snap Package Store: ${SNAP_STORE_DIR} ===${RESET}"
    echo ""

    if [[ ! -d "${SNAP_STORE_DIR}" ]]; then
        echo -e "${YELLOW}Snap store directory does not exist yet: ${SNAP_STORE_DIR}${RESET}"
        echo "Run 'sudo bash install.sh' or 'sudo bash scripts/install_snaps.sh' to populate it."
        echo ""
        return
    fi

    local snaps=()
    while IFS= read -r -d '' f; do
        snaps+=("$f")
    done < <(find "${SNAP_STORE_DIR}" -maxdepth 1 -name "*.snap" -print0 2>/dev/null | sort -z)

    if [[ ${#snaps[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No .snap files found in ${SNAP_STORE_DIR}.${RESET}"
        echo "Run 'sudo bash install.sh' or 'sudo bash scripts/install_snaps.sh' to populate it."
        echo ""
        return
    fi

    printf "  %-35s %s\n" "Package" "Status"
    printf "  %-35s %s\n" "-------" "------"

    for snap_file in "${snaps[@]}"; do
        local name
        name="$(snap_display_name "${snap_file}")"
        if is_snap_installed "${name}"; then
            printf "  ${GREEN}%-35s ${GREEN}[INSTALLED]${RESET}\n" "${name}"
        else
            printf "  ${RED}%-35s ${RED}[NOT INSTALLED]${RESET}\n" "${name}"
        fi
    done
    echo ""
}

# ---------------------------------------------------------------------------
# Install a single snap from the store directory
# ---------------------------------------------------------------------------
install_snap_from_store() {
    local name="$1"
    local snap_file="${SNAP_STORE_DIR}/${name}.snap"

    if [[ ! -f "${snap_file}" ]]; then
        echo -e "${RED}Error: ${snap_file} not found in store.${RESET}" >&2
        return 1
    fi

    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}Root required to install snaps. Re-running with sudo...${RESET}"
        exec sudo bash "${BASH_SOURCE[0]}"
    fi

    echo "Installing ${name} from ${snap_file} ..."
    snap install --dangerous "${snap_file}" && \
        echo -e "${GREEN}${name} installed successfully.${RESET}" || \
        echo -e "${RED}Failed to install ${name}. Try: snap install --classic --dangerous ${snap_file}${RESET}"
}

# ---------------------------------------------------------------------------
# Install all snaps in the store that are not already installed
# ---------------------------------------------------------------------------
install_all_missing_snaps() {
    if [[ ! -d "${SNAP_STORE_DIR}" ]]; then
        echo -e "${RED}Snap store directory not found: ${SNAP_STORE_DIR}${RESET}" >&2
        return 1
    fi

    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}Root required to install snaps. Re-running with sudo...${RESET}"
        exec sudo bash "${BASH_SOURCE[0]}"
    fi

    local installed_count=0
    while IFS= read -r -d '' snap_file; do
        local name
        name="$(snap_display_name "${snap_file}")"
        if ! is_snap_installed "${name}"; then
            echo "Installing ${name} ..."
            snap install --dangerous "${snap_file}" && \
                echo -e "${GREEN}${name} installed.${RESET}" || \
                echo -e "${YELLOW}Could not install ${name} (may need --classic flag).${RESET}"
            (( installed_count++ )) || true
        fi
    done < <(find "${SNAP_STORE_DIR}" -maxdepth 1 -name "*.snap" -print0 2>/dev/null | sort -z)

    if [[ ${installed_count} -eq 0 ]]; then
        echo "All snaps in the store are already installed."
    fi
}

# ---------------------------------------------------------------------------
# Print the main menu header
# ---------------------------------------------------------------------------
print_header() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║       Drifting Bubble OS  –  Manager         ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ---------------------------------------------------------------------------
# Main menu loop
# ---------------------------------------------------------------------------
main_menu() {
    while true; do
        print_header
        show_snap_status

        echo -e "${BOLD}Options:${RESET}"
        echo "  1) Install a snap package from the local store"
        echo "  2) Install all missing snap packages from the store"
        echo "  3) Run full system installation (apt + snaps + fileshare)"
        echo "  4) Set up Samba file share only"
        echo "  5) Refresh snap status"
        echo "  q) Quit"
        echo ""
        read -r -p "Choose an option: " choice

        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

        case "${choice}" in
            1)
                read -r -p "Enter snap name (without .snap extension): " snap_name
                install_snap_from_store "${snap_name}"
                read -r -p "Press Enter to continue..." _
                ;;
            2)
                install_all_missing_snaps
                read -r -p "Press Enter to continue..." _
                ;;
            3)
                if [[ $EUID -ne 0 ]]; then
                    echo -e "${YELLOW}Root required. Re-running with sudo...${RESET}"
                    exec sudo bash "${SCRIPT_DIR}/install.sh"
                fi
                bash "${SCRIPT_DIR}/install.sh"
                read -r -p "Press Enter to continue..." _
                ;;
            4)
                if [[ $EUID -ne 0 ]]; then
                    echo -e "${YELLOW}Root required. Re-running with sudo...${RESET}"
                    exec sudo bash "${SCRIPT_DIR}/scripts/setup_fileshare.sh"
                fi
                bash "${SCRIPT_DIR}/scripts/setup_fileshare.sh"
                read -r -p "Press Enter to continue..." _
                ;;
            5)
                # just loop back to refresh the display
                ;;
            q|Q)
                echo "Goodbye."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option.${RESET}"
                sleep 1
                ;;
        esac
    done
}

main_menu
