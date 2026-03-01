#!/usr/bin/env bash
# Drifting Bubble OS - APT Package Installer
# Installs offline-capable tools and services via apt.
#
# Usage: sudo bash scripts/install_apt_packages.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

echo "--- Updating package lists ---"
apt-get update -y

# ---------------------------------------------------------------------------
# Core utilities
# ---------------------------------------------------------------------------
echo "--- Installing core utilities ---"
apt-get install -y \
    curl \
    wget \
    git \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# ---------------------------------------------------------------------------
# Ensure multiverse repository is available
# ---------------------------------------------------------------------------
echo "--- Update source list to pull from additional repositories ---"
add-apt-repository -y multiverse

echo "--- Updating package lists ---"
apt-get update -y

# ---------------------------------------------------------------------------
# Pre-download restricted extras for increased usability compatibility and file conversions
# ---------------------------------------------------------------------------
echo "--- Download restricted extras so they are available for install by users who need to accept license ---"
apt install --download-only ubuntu-restricted-extras

# ---------------------------------------------------------------------------
# Kiwix tools – offline Wikipedia / knowledge base reader (CLI tools)
# ---------------------------------------------------------------------------
echo "--- Installing Kiwix tools ---"
apt-get install -y kiwix-tools || {
    # Fall back to snap if not in default repos (see install_snaps.sh)
    echo "kiwix-tools not found in apt repos; will be installed via snap." >&2
}

# ---------------------------------------------------------------------------
# Torrent client (headless, daemon-friendly)
# ---------------------------------------------------------------------------
echo "--- Installing torrent clients (qbittorrent-nox / deluge) ---"
apt-get install -y qbittorrent-nox deluge

# ---------------------------------------------------------------------------
# File sharing – Samba (see setup_fileshare.sh for configuration)
# ---------------------------------------------------------------------------
echo "--- Installing Samba ---"
apt-get install -y samba samba-common-bin

# ---------------------------------------------------------------------------
# Network tools and common network servers (DNS/DHCP/diagnostics)
# ---------------------------------------------------------------------------
echo "--- Installing network tools and network server packages ---"
apt-get install -y \
    openssh-client \
    openssh-server \
    bind9 \
    dnsutils \
    kea \
    net-tools \
    iproute2 \
    iputils-ping \
    traceroute \
    nmap \
    tcpdump \
    netcat-openbsd

# ---------------------------------------------------------------------------
# Archives / compression tools
# ---------------------------------------------------------------------------
echo "--- Installing 7zip tools ---"
apt-get install -y \
    p7zip \
    p7zip-full

# ---------------------------------------------------------------------------
# Hardware drivers helper
# ---------------------------------------------------------------------------
echo "--- Installing ubuntu-drivers-common ---"
apt-get install -y ubuntu-drivers-common

# ---------------------------------------------------------------------------
# Cubic – Ubuntu live-CD / OS builder (via official PPA)
# ---------------------------------------------------------------------------
echo "--- Adding Cubic PPA and installing ---"
add-apt-repository -y ppa:cubic-wizard/release
apt-get update -y
apt-get install -y cubic

# ---------------------------------------------------------------------------
# Desktop environments (GNOME / KDE) - full installs by default
# ---------------------------------------------------------------------------
echo "--- Installing GNOME and KDE desktop environments ---"
apt-get install --download-only -y \
    ubuntu-desktop \
    kubuntu-desktop

# ---------------------------------------------------------------------------
# Language support (base English + common packs)
# ---------------------------------------------------------------------------
echo "--- Installing language support ---"
apt-get install -y \
    language-pack-en \
    language-pack-en-base \
    fonts-noto \
    fonts-noto-cjk

# ---------------------------------------------------------------------------
# Light communication tools
# ---------------------------------------------------------------------------
echo "--- Installing light communication tools ---"
# Mumble – low-latency voice chat (works on LAN without internet)
apt-get install -y mumble mumble-server
# IRC client for text chat
apt-get install -y irssi

echo ""
echo "=== APT package installation complete ==="
