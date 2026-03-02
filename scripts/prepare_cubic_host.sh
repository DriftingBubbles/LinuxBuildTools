#!/usr/bin/env bash
# Drifting Bubble OS - Cubic Host Preparation
# Prepares an Ubuntu/Debian host to build custom Ubuntu ISOs with Cubic.
#
# What this script does:
# 1) Installs Cubic and required host packages
# 2) Downloads the latest available Ubuntu Desktop AMD64 ISO
# 3) Creates host source directories for media, ZIM files, and torrents
#
# Usage:
#   sudo bash scripts/prepare_cubic_host.sh
#
# Environment variables:
#   CUBIC_HOST_ROOT      Base directory for host-side Cubic assets
#                        (default: /shared/cubic)
#   UBUNTU_RELEASES_URL  Ubuntu releases index URL
#                        (default: https://releases.ubuntu.com/)
#   ISO_VERSION          Optional explicit Ubuntu version (e.g. 24.04.2)
#                        If set, script downloads that version directly.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

CUBIC_HOST_ROOT="${CUBIC_HOST_ROOT:-/shared/cubic}"
UBUNTU_RELEASES_URL="${UBUNTU_RELEASES_URL:-https://releases.ubuntu.com/}"
ISO_VERSION="${ISO_VERSION:-}"

ISO_DIR="${CUBIC_HOST_ROOT}/iso"
SRC_DIR="${CUBIC_HOST_ROOT}/source"
MEDIA_DIR="${SRC_DIR}/media"
ZIM_DIR="${SRC_DIR}/zim"
TORRENTS_DIR="${SRC_DIR}/torrents"
INSTALLERS_DIR="${SRC_DIR}/installers"
TRANSFER_DIR="${SRC_DIR}/transfer"
PROJECT_DIR="${CUBIC_HOST_ROOT}/projects"

ensure_prereqs() {
    echo "--- Installing prerequisite packages ---"
    apt-get update -y
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        wget \
        curl \
        rsync
}

install_cubic() {
    echo "--- Installing Cubic ---"
    add-apt-repository -y ppa:cubic-wizard/release
    apt-get update -y
    apt-get install -y cubic
}

version_sort_key() {
    echo "$1" | awk -F. '{printf "%03d%03d%03d\n", $1, $2, $3}'
}

detect_latest_iso_url() {
    local releases_html
    releases_html="$(curl -fsSL "${UBUNTU_RELEASES_URL}")"

    local versions
    versions="$(echo "${releases_html}" \
        | grep -Eo '[0-9]{2}\.[0-9]{2}(\.[0-9]+)?/' \
        | tr -d '/' \
        | sort -u)"

    if [[ -z "${versions}" ]]; then
        echo "Error: could not detect Ubuntu versions from ${UBUNTU_RELEASES_URL}" >&2
        return 1
    fi

    local latest_version=""
    local latest_key=""
    while IFS= read -r version; do
        [[ -z "${version}" ]] && continue
        local key
        key="$(version_sort_key "${version}")"
        if [[ -z "${latest_key}" || "${key}" > "${latest_key}" ]]; then
            latest_key="${key}"
            latest_version="${version}"
        fi
    done <<< "${versions}"

    if [[ -z "${latest_version}" ]]; then
        echo "Error: failed to determine latest Ubuntu version." >&2
        return 1
    fi

    echo "${UBUNTU_RELEASES_URL%/}/${latest_version}/ubuntu-${latest_version}-desktop-amd64.iso"
}

download_iso() {
    mkdir -p "${ISO_DIR}"

    local iso_url=""
    if [[ -n "${ISO_VERSION}" ]]; then
        iso_url="${UBUNTU_RELEASES_URL%/}/${ISO_VERSION}/ubuntu-${ISO_VERSION}-desktop-amd64.iso"
        echo "--- Using requested ISO version: ${ISO_VERSION} ---"
    else
        echo "--- Detecting latest Ubuntu Desktop ISO ---"
        iso_url="$(detect_latest_iso_url)"
    fi

    local iso_file
    iso_file="$(basename "${iso_url}")"
    local iso_path="${ISO_DIR}/${iso_file}"

    echo "--- Downloading Ubuntu ISO ---"
    echo "Source: ${iso_url}"
    echo "Target: ${iso_path}"

    wget -c -O "${iso_path}" "${iso_url}"
}

create_source_directories() {
    echo "--- Creating host source directories ---"
    mkdir -p \
        "${MEDIA_DIR}" \
        "${ZIM_DIR}" \
        "${TORRENTS_DIR}" \
        "${INSTALLERS_DIR}" \
        "${TRANSFER_DIR}" \
        "${PROJECT_DIR}"

    if [[ -n "${SUDO_USER:-}" ]]; then
        chown -R "${SUDO_USER}:${SUDO_USER}" "${CUBIC_HOST_ROOT}"
    fi
}

print_summary() {
    echo ""
    echo "=== Cubic host preparation complete ==="
    echo "Root: ${CUBIC_HOST_ROOT}"
    echo "ISO directory: ${ISO_DIR}"
    echo "Cubic projects: ${PROJECT_DIR}"
    echo "Source media dir: ${MEDIA_DIR}"
    echo "Source ZIM dir: ${ZIM_DIR}"
    echo "Source torrents dir: ${TORRENTS_DIR}"
    echo "Source installers dir: ${INSTALLERS_DIR}"
    echo "Transfer staging dir: ${TRANSFER_DIR}"
    echo ""
    echo "Recommendation: Before building with Cubic (or before any loss of internet access),"
    echo "download and place critical data into the shared source folders now:"
    echo "  - ${MEDIA_DIR}"
    echo "  - ${ZIM_DIR}"
    echo "  - ${TORRENTS_DIR}"
    echo "  - ${INSTALLERS_DIR}"
    echo ""
    echo "Next steps:"
    echo "1) Launch Cubic and create a project under: ${PROJECT_DIR}"
    echo "2) Use ISO from: ${ISO_DIR}"
    echo "3) Copy source content from: ${SRC_DIR} into your Cubic project/image"
}

ensure_prereqs
install_cubic
download_iso
create_source_directories
print_summary
