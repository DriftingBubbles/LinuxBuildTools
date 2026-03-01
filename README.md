# LinuxBuildTools – Drifting Bubble OS Build Tools

Bash scripts to build and manage a **Drifting Bubble OS** — a self-contained,
offline-capable Linux environment providing a free library of knowledge, media,
utilities, and entertainment that can be shared over a local network.

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

---

## Repository Layout

```
LinuxBuildTools/
├── install.sh                    # Main orchestration script (run first)
├── menu.sh                       # Interactive system management menu
└── scripts/
    ├── install_apt_packages.sh   # Install packages via apt
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
Top-level installer. Runs the three sub-scripts in order:
1. `scripts/install_apt_packages.sh`
2. `scripts/install_snaps.sh`
3. `scripts/setup_fileshare.sh`

```bash
sudo bash install.sh
```

### `scripts/install_apt_packages.sh`
Installs all APT packages: kiwix-tools, qbittorrent-nox, Samba, Cubic,
ubuntu-drivers-common, language packs, Mumble, irssi.

```bash
sudo bash scripts/install_apt_packages.sh
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
- Can run the full installer or set up the file share from the menu.

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

---

## License

[GPL-3.0](LICENSE)
