# LinuxBuildTools – Drifting Bubble OS Build Tools

Bash scripts to build and manage a **Drifting Bubble OS** — a self-contained,
offline-capable Linux environment providing a free library of knowledge, media,
utilities, and entertainment that can be shared over a local network.

## Philosophy

The core idea behind **Drifting Bubble** is to create a portable "bubble" of
offline internet knowledge that people can carry, replicate, and share.

When internet access is limited or unavailable, this project helps communities
keep access to practical information, learning materials, and communication
tools. As people move between locations, that knowledge bubble can "drift"
with them and be re-shared locally, helping others reconnect to essential
resources without depending on live internet access.

---

## Requirements

- Ubuntu/Debian-based Linux
- `sudo` access for install/setup scripts
- `snapd` for snap-based scripts
- `rsync` or `wget` (and optionally `curl`) for Kiwix torrent retrieval

## Path conventions

- Snap download cache/staging: `/shared/snaps`
- Kiwix torrent staging: `/share/torrent/zim`
- Cubic host workspace root: `/shared/cubic`

---

## Features

| Category | Tool / Package |
|---|---|
| Offline knowledge | [Kiwix](https://www.kiwix.org/) + Wikipedia ZIM files |
| Media server | [Plex Media Server](https://www.plex.tv/) |
| File sharing | Samba (browse share via LAN) |
| Torrent client | qBittorrent-nox (headless) / Transmission (snap) |
| Hardware drivers | `ubuntu-drivers-common` |
| OS image builder | [Cubic](https://launchpad.net/cubic) |
| Communication | Mumble (LAN voice), irssi (IRC), Signal Desktop |
| Language support | Ubuntu language packs + Noto fonts |

Additional reference guides:
- [Public Domain & Open Knowledge Resources](PUBLIC_DOMAIN_RESOURCES.md)
- [Offline Knowledge Continuity Guide](OFFLINE_KNOWLEDGE_README.md)
- [Cubic ISO Creation Guide](CUBIC_ISO_GUIDE.md)

---

## Repository Layout

```
LinuxBuildTools/
├── install.sh                    # Main orchestration script (run first)
├── menu.sh                       # Interactive system management menu
├── README.md
├── PUBLIC_DOMAIN_RESOURCES.md
├── OFFLINE_KNOWLEDGE_README.md
├── CUBIC_ISO_GUIDE.md
├── resources/
└── scripts/
    ├── install_apt_packages.sh   # Install packages via apt
   ├── install_language_support.sh # Install selected language support packs
   ├── download_utility_snaps.sh # Download utility snaps to /shared/snaps
   ├── download_entertainment_snaps.sh # Download game snaps to /shared/snaps
   ├── download_emulator_snaps.sh # Download emulator snaps to /shared/snaps
   ├── download_server_snaps.sh # Download server snaps to /shared/snaps
   ├── download_productivity_snaps.sh # Download productivity snaps to /shared/snaps
   ├── download_kiwix_torrents.sh # Download latest Kiwix .zim.torrent files
   ├── prepare_cubic_host.sh # Prepare host for Cubic + Ubuntu ISO download
   ├── move_cubic_share_to_root.sh # Move host Cubic source dirs into Cubic root
    ├── install_snaps.sh          # Install & cache packages via snap
    └── setup_fileshare.sh        # Configure Samba LAN file share
```

---

## Quick Start

```bash
# 1. Clone the repo onto your Ubuntu machine
git clone https://github.com/DriftingBubbles/LinuxBuildTools.git
cd LinuxBuildTools

# 2. Run the full installer (requires root)
sudo bash install.sh

# 3. Launch the interactive management menu
bash menu.sh
```

---

## Scripts

### `install.sh`
Top-level installer. Runs the sub-scripts in order:
1. `scripts/install_apt_packages.sh`
2. `scripts/install_language_support.sh`
3. `scripts/install_snaps.sh`
4. `scripts/download_utility_snaps.sh`
5. `scripts/download_entertainment_snaps.sh`
6. `scripts/download_emulator_snaps.sh`
7. `scripts/download_server_snaps.sh`
8. `scripts/download_productivity_snaps.sh`
9. `scripts/setup_fileshare.sh`

Note: `scripts/download_kiwix_torrents.sh` is an optional/manual content step
and is not part of `install.sh` by default.

```bash
sudo bash install.sh
```

### `scripts/install_apt_packages.sh`
Installs all APT packages: kiwix-tools, qbittorrent-nox, Samba, Cubic,
ubuntu-drivers-common, language packs, Mumble, irssi.

```bash
sudo bash scripts/install_apt_packages.sh
```

### `scripts/install_language_support.sh`
Installs locale + language support for these languages:
German, Japanese, French, Spanish, English, Italian, Ukrainian,
Polish, Danish, Finnish, Portuguese, and Chinese.

```bash
sudo bash scripts/install_language_support.sh
```

### `scripts/install_snaps.sh`
Installs snap packages and **caches them** to a local snap store directory
(`/opt/drifting-bubble/snaps` by default) so they can be re-installed offline
on other machines.

```bash
sudo bash scripts/install_snaps.sh

# Use a custom cache directory
SNAP_STORE_DIR=/media/usb/snaps sudo bash scripts/install_snaps.sh
```

### `scripts/download_utility_snaps.sh`
Uses `snap download` to fetch utility snaps (and `.assert` files) into
`/shared/snaps` by default for these locale contexts: English, Spanish, French.

Requested apps included:
- Kiwix
- FFmpeg2
- VLC Player
- Firefox
- Opera
- Chromium
- Plex
- Postgres
- pgAdmin4
- Visual Studio Code
- Dolphin file manager
- Krita
- GIMP
- Inkscape

```bash
sudo bash scripts/download_utility_snaps.sh

# Use a custom download directory
SNAP_DOWNLOAD_DIR=/media/usb/snaps sudo bash scripts/download_utility_snaps.sh
```

### `scripts/download_entertainment_snaps.sh`
Uses `snap download` to fetch popular free game snaps (and `.assert` files)
into `/shared/snaps` by default for these categories:
- Arcade style
- Board game style
- Go
- Reversi
- Solitaire
- Card game style

```bash
sudo bash scripts/download_entertainment_snaps.sh

# Use a custom download directory
SNAP_DOWNLOAD_DIR=/media/usb/snaps sudo bash scripts/download_entertainment_snaps.sh
```

### `scripts/download_emulator_snaps.sh`
Uses `snap download` to fetch popular emulator snaps (and `.assert` files)
into `/shared/snaps` by default.

```bash
sudo bash scripts/download_emulator_snaps.sh

# Use a custom download directory
SNAP_DOWNLOAD_DIR=/media/usb/snaps sudo bash scripts/download_emulator_snaps.sh
```

### `scripts/download_server_snaps.sh`
Uses `snap download` to fetch popular server snaps (and `.assert` files)
into `/shared/snaps` by default.

```bash
sudo bash scripts/download_server_snaps.sh

# Use a custom download directory
SNAP_DOWNLOAD_DIR=/media/usb/snaps sudo bash scripts/download_server_snaps.sh
```

### `scripts/download_productivity_snaps.sh`
Uses `snap download` to fetch popular productivity snaps (and `.assert` files)
into `/shared/snaps` by default.

```bash
sudo bash scripts/download_productivity_snaps.sh

# Use a custom download directory
SNAP_DOWNLOAD_DIR=/media/usb/snaps sudo bash scripts/download_productivity_snaps.sh
```

### `scripts/download_kiwix_torrents.sh`
Discovers current Kiwix `.zim` files, derives matching `.zim.torrent`
paths, and stores them in `/share/torrent/zim` by default.

```bash
bash scripts/download_kiwix_torrents.sh

# Use a custom destination directory
KIWIX_TORRENT_DIR=/media/usb/torrent/zim bash scripts/download_kiwix_torrents.sh
```

### `scripts/prepare_cubic_host.sh`
Prepares a host system for Cubic ISO building by installing Cubic,
downloading the latest Ubuntu Desktop ISO, and creating host source
directories for media, ZIM files, torrents, and installers.

```bash
sudo bash scripts/prepare_cubic_host.sh

# Optional custom host root path
CUBIC_HOST_ROOT=/data/cubic sudo bash scripts/prepare_cubic_host.sh

# Optional explicit Ubuntu version
ISO_VERSION=24.04.2 sudo bash scripts/prepare_cubic_host.sh
```

### Cubic workflow helpers

Use these together when building a custom ISO with Cubic:

- `scripts/prepare_cubic_host.sh`
   - Installs Cubic, fetches Ubuntu ISO, and prepares host staging folders.
- `scripts/move_cubic_share_to_root.sh`
   - Moves staged host content into Cubic root share paths and sets `root:users` ownership.

### `scripts/move_cubic_share_to_root.sh`
Moves content from host Cubic source directories into the Cubic root
environment share directory, then sets ownership to `root:users`.

```bash
sudo bash scripts/move_cubic_share_to_root.sh

# Run outside Cubic shell/chroot by targeting a specific Cubic rootfs path
CUBIC_ROOT=/path/to/cubic-project/custom-root sudo bash scripts/move_cubic_share_to_root.sh
```

### `scripts/setup_fileshare.sh`
Configures a read-only Samba share (`DriftingBubble`) pointing to
`/srv/drifting-bubble`. Devices on the same network can browse to
`\\<host-ip>\DriftingBubble` without a password.

```bash
sudo bash scripts/setup_fileshare.sh

# Custom share root and name
SHARE_ROOT=/media/data SHARE_NAME=MyShare sudo bash scripts/setup_fileshare.sh
```

### `menu.sh`
Interactive bash menu that:
- Scans the local snap store directory for `.snap` files.
- Shows each package with **[INSTALLED]** or **[NOT INSTALLED]** status.
- Lets you install individual snaps or all missing snaps in one step.
- Can run the full installer and all configured snap download groups.

Current menu options include:
- Full install and file-share setup
- Language support installer
- Utility, entertainment, emulator, server, and productivity snap downloads
- Snap status refresh

Menu option map:

| Option | Action |
|---|---|
| 1 | Install a single snap from local store |
| 2 | Install all missing snaps from local store |
| 3 | Run `install.sh` |
| 4 | Run `scripts/setup_fileshare.sh` |
| 5 | Run `scripts/install_language_support.sh` |
| 6 | Run `scripts/download_utility_snaps.sh` |
| 7 | Run `scripts/download_entertainment_snaps.sh` |
| 8 | Run `scripts/download_emulator_snaps.sh` |
| 9 | Run `scripts/download_server_snaps.sh` |
| 10 | Run `scripts/download_productivity_snaps.sh` |
| 11 | Refresh status view |
| q | Quit menu |

```bash
bash menu.sh

# Point at a different snap store (e.g. from a USB drive)
SNAP_STORE_DIR=/media/usb/snaps bash menu.sh
```

---

## Offline Distribution

1. Run `install.sh` on the first (online) machine to populate
   `/opt/drifting-bubble/snaps` with cached `.snap` files.
2. Copy `/opt/drifting-bubble/snaps` to a USB drive or expose it over the
   Samba share.
3. On the next machine, set `SNAP_STORE_DIR` to the USB path and run
   `menu.sh` → *Install all missing snap packages from the store*.

For Kiwix content torrents, run `scripts/download_kiwix_torrents.sh` and share
the `/share/torrent/zim` directory (or your custom `KIWIX_TORRENT_DIR`).

---

## Roadmap

Planned future additions to strengthen the Drifting Bubble model of portable,
shareable offline internet knowledge.

### 1) Recommended minimum ZIM bundle profiles

Define and automate baseline ZIM profiles for quick deployment:
- Core profile: Wikipedia (Simple/EN selected), Wiktionary, Wikibooks
- Education profile: Wikiversity and foundational STEM/reference collections
- Health & resilience profile: medical/public-health and sanitation references
- Culture profile: language-learning and public-domain literature indexes

Potential deliverables:
- Scripted profile manifests (`core`, `education`, `health`, `full`)
- Size estimates per profile for USB/LAN planning
- Validation checks to ensure required files exist before sharing

### 2) Additional recommended snap packs

Expand downloadable snap groups beyond current utility/server/productivity sets:
- Collaboration pack: chat/messaging and coordination tools
- Learning pack: math/science tools and offline readers
- Recovery/admin pack: backup, recovery, and monitoring utilities
- Accessibility pack: text-to-speech and inclusive communication tools

Potential deliverables:
- New category scripts (`download_collaboration_snaps.sh`, etc.)
- Unified manifest export of downloaded snap artifacts
- Optional `minimal` vs `full` selection flags

### 3) Post-install support and sharing bootstrap

Add post-install helpers so systems are immediately ready to host and share
knowledge content with minimal manual setup.

Planned capabilities:
- Guided first-boot setup for share paths and ownership
- One-command content indexing for media, ZIM files, torrents, and installers
- Automatic permissions/group checks for shared folders
- LAN discoverability helpers (hostname, share status, access instructions)
- "Bubble readiness" health checks (content present + services running)

Goal: make it simple for any freshly installed machine to become a reliable
node in a drifting, offline internet knowledge bubble.

## Validation matrix

| Check | Expected result |
|---|---|
| Boot | ISO boots to installer/live environment |
| Install | Installation completes without critical errors |
| Network | Wired/Wi-Fi networking works after install |
| Scripts | `install.sh` and key script groups run successfully |
| Menu | `menu.sh` options execute expected actions |
| File share | Samba share is reachable from LAN clients |
| Content paths | `/shared/snaps`, `/share/torrent/zim`, `/shared/cubic` populated as intended |

---

## License

[GPL-3.0](LICENSE)
