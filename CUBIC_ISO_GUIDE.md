# Cubic ISO Creation Guide

This guide explains how to use **Cubic** (Custom Ubuntu ISO Creator) to build a shareable Ubuntu-based ISO, and how scripts in this repository help prepare and maintain that build.

## What Cubic is

Cubic is a GUI tool for customizing Ubuntu ISO images.
- Official project page: https://launchpad.net/cubic
- Typical use: unpack an Ubuntu ISO, customize packages/files/settings, then generate a new ISO.

## High-level workflow

1. Start from an official Ubuntu ISO.
2. Open Cubic and create a new project directory.
3. Customize the unpacked root filesystem.
4. Add your project scripts and content.
5. Build a new ISO.
6. Test in a VM.
7. Share the validated ISO.

---

## Step-by-step

## 1) Prepare host machine

On your Ubuntu host machine:
- Install this repository and run base setup tools as needed.
- Ensure Cubic is installed (this repo installs it via [scripts/install_apt_packages.sh](scripts/install_apt_packages.sh)).

Recommended one-step host preparation:

```bash
sudo bash scripts/prepare_cubic_host.sh
```

This script installs Cubic, downloads the latest Ubuntu Desktop ISO, and creates
host source directories for media, ZIM files, torrents, and installers.

Optional prep commands:

```bash
sudo bash scripts/install_apt_packages.sh
sudo bash scripts/install_snaps.sh
```

## 2) Download base Ubuntu ISO

- Download an official Ubuntu ISO from Ubuntu releases.
- Keep checksum/signature files and verify integrity before use.

## 3) Create Cubic project

1. Launch Cubic.
2. Select a new project directory (for example: `/opt/cubic/my-build`).
3. Choose your base Ubuntu ISO.
4. Let Cubic extract the filesystem.

## 4) Customize inside Cubic shell

In Cubic’s terminal stage, you can:
- Install/remove packages.
- Copy your scripts into the image (for example, this repo under `/opt/LinuxBuildTools`).
- Add default configuration and data directories.

Recommended pattern:
- Include this repository in the image.
- Keep scripts executable (`chmod +x`).
- Avoid hard-coding machine-specific paths.

To move staged host content into the Cubic root share path:

```bash
sudo bash scripts/move_cubic_share_to_root.sh
```

If running outside the Cubic shell/chroot, target the extracted rootfs path:

```bash
CUBIC_ROOT=/path/to/cubic-project/custom-root sudo bash scripts/move_cubic_share_to_root.sh
```

## 5) Use repository scripts during customization

These scripts are useful during ISO preparation and for post-install use:

- [install.sh](install.sh)
  - Full orchestrated setup on target machines.
- [scripts/install_apt_packages.sh](scripts/install_apt_packages.sh)
  - Installs core APT packages, including Cubic-related dependencies and system tools.
- [scripts/install_language_support.sh](scripts/install_language_support.sh)
  - Adds selected language locales/fonts/input support.
- [scripts/install_snaps.sh](scripts/install_snaps.sh)
  - Installs and caches snap packages for offline reuse.
- [scripts/download_utility_snaps.sh](scripts/download_utility_snaps.sh)
  - Prefetches utility app snaps to `/shared/snaps`.
- [scripts/download_entertainment_snaps.sh](scripts/download_entertainment_snaps.sh)
  - Prefetches entertainment/game snaps.
- [scripts/download_emulator_snaps.sh](scripts/download_emulator_snaps.sh)
  - Prefetches emulator snaps.
- [scripts/download_server_snaps.sh](scripts/download_server_snaps.sh)
  - Prefetches server snaps.
- [scripts/download_productivity_snaps.sh](scripts/download_productivity_snaps.sh)
  - Prefetches productivity snaps.
- [scripts/download_kiwix_torrents.sh](scripts/download_kiwix_torrents.sh)
  - Pulls Kiwix `.zim.torrent` files for offline knowledge collection.
- [scripts/setup_fileshare.sh](scripts/setup_fileshare.sh)
  - Configures local Samba share for LAN distribution.
- [menu.sh](menu.sh)
  - Interactive operator menu for repeatable operations after installation.

## 6) Configure boot/user experience in Cubic

Before building:
- Set a clear ISO name/version in Cubic.
- Add release notes/changelog text for your build.
- Keep branding/version strings consistent with repository docs.

## 7) Build the custom ISO

In Cubic:
1. Proceed to the Generate page.
2. Select output filename/version.
3. Build the ISO.

Output is written to your Cubic project output folder.

## 8) Test before sharing

Test in a virtual machine (VirtualBox/KVM/VMware):
- Installer boots and completes normally.
- Network works.
- `install.sh` and `menu.sh` run successfully.
- Snap cache and optional content directories are present.
- Samba share setup behaves as expected.

## 9) Share the ISO

For distribution:
- Include checksum files (`sha256sum`) with the ISO.
- Include short build notes and script versions.
- Keep a copy of your Cubic project directory for reproducibility.

---

## Suggested release checklist

- Base ISO checksum verified
- Cubic project saved/versioned
- Custom scripts included and executable
- Full install path tested (`install.sh`)
- Menu path tested (`menu.sh`)
- ISO boot/install tested in VM
- ISO checksum generated and published
- Notes + known issues documented

---

## Related documentation

- [README.md](README.md)
- [OFFLINE_KNOWLEDGE_README.md](OFFLINE_KNOWLEDGE_README.md)
- [PUBLIC_DOMAIN_RESOURCES.md](PUBLIC_DOMAIN_RESOURCES.md)
