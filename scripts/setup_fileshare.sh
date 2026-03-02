#!/usr/bin/env bash
# Drifting Bubble OS - Samba File Share Setup
# Configures a Samba share so other LAN devices can browse and download
# content from this machine without internet access.
#
# Usage: sudo bash scripts/setup_fileshare.sh
#
# Environment variables:
#   SHARE_ROOT  – directory to expose over Samba
#                 (default: /srv/drifting-bubble)
#   SHARE_NAME  – Samba share name shown to clients
#                 (default: DriftingBubble)

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

SHARE_ROOT="${SHARE_ROOT:-/srv/drifting-bubble}"
SHARE_NAME="${SHARE_NAME:-DriftingBubble}"
SMB_CONF="/etc/samba/smb.conf"
BACKUP_CONF="${SMB_CONF}.bak.$(date +%Y%m%d%H%M%S)"

# ---------------------------------------------------------------------------
# Ensure Samba is installed
# ---------------------------------------------------------------------------
if ! command -v smbd &>/dev/null; then
    echo "Samba not found – installing ..."
    apt-get install -y samba samba-common-bin
fi

# ---------------------------------------------------------------------------
# Create share directory
# ---------------------------------------------------------------------------
echo "--- Creating share root: ${SHARE_ROOT} ---"
mkdir -p "${SHARE_ROOT}"
chmod 0755 "${SHARE_ROOT}"

# ---------------------------------------------------------------------------
# Back up existing smb.conf, then append share stanza
# ---------------------------------------------------------------------------
if [[ -f "${SMB_CONF}" ]]; then
    cp "${SMB_CONF}" "${BACKUP_CONF}"
    echo "Backed up existing smb.conf to ${BACKUP_CONF}"
fi

# Remove any previous DriftingBubble stanza so we don't duplicate it
if grep -q "\[${SHARE_NAME}\]" "${SMB_CONF}" 2>/dev/null; then
    echo "Existing [${SHARE_NAME}] stanza found – removing before re-adding ..."
    # Delete from [ShareName] to just before the next section header or end of file
    python3 - "${SMB_CONF}" "${SHARE_NAME}" <<'PYEOF'
import sys, re
conf_path, section = sys.argv[1], sys.argv[2]
with open(conf_path, 'r') as fh:
    content = fh.read()
# Remove the named section and all its lines up to (but not including) the
# next [section] header or end of file.
pattern = r'\n?\[' + re.escape(section) + r'\][^\[]*'
content = re.sub(pattern, '', content)
with open(conf_path, 'w') as fh:
    fh.write(content)
PYEOF
fi

cat >> "${SMB_CONF}" <<EOF

[${SHARE_NAME}]
   comment = Drifting Bubble OS - Offline Knowledge & Media Share
   path = ${SHARE_ROOT}
   browseable = yes
   read only = yes
   guest ok = yes
   create mask = 0644
   directory mask = 0755
EOF

echo "--- Share [${SHARE_NAME}] added to ${SMB_CONF} ---"

# ---------------------------------------------------------------------------
# Reload Samba
# ---------------------------------------------------------------------------
manage_service_if_present() {
    local unit_name="$1"

    if systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -qx "${unit_name}.service"; then
        systemctl enable "${unit_name}"
        systemctl restart "${unit_name}"
    else
        echo "Service not found, skipping: ${unit_name}.service"
    fi
}

manage_service_if_present "smbd"
manage_service_if_present "nmbd"

echo ""
echo "=== Samba file share setup complete ==="
echo "Share name : ${SHARE_NAME}"
echo "Share path : ${SHARE_ROOT}"
echo "Connect via: \\\\$(hostname -I | awk '{print $1}')\\${SHARE_NAME}"
echo ""
echo "Place content (ZIM files, media, snap packages, etc.) in ${SHARE_ROOT}"
echo "to make it available to all devices on the local network."
