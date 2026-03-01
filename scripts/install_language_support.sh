#!/usr/bin/env bash
# Drifting Bubble OS - Language Support Installer
# Installs language packs, locales, dictionaries, and common fonts/input tools
# for selected languages on Ubuntu/Debian-based Linux.
#
# Usage: sudo bash scripts/install_language_support.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

echo "--- Updating package lists ---"
apt-get update -y

install_if_available() {
    local package_name="$1"
    if apt-cache show "${package_name}" &>/dev/null; then
        apt-get install -y "${package_name}"
    else
        echo "Skipping unavailable package: ${package_name}"
    fi
}

install_many_if_available() {
    for package_name in "$@"; do
        install_if_available "${package_name}"
    done
}

echo "--- Installing core language support tools ---"
install_many_if_available \
    locales \
    language-selector-common \
    hunspell \
    aspell \
    fonts-noto \
    fonts-noto-core \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    ibus \
    ibus-m17n \
    ibus-libpinyin \
    ibus-anthy

echo "--- Generating UTF-8 locales for selected languages ---"
for locale_name in \
    en_US.UTF-8 \
    de_DE.UTF-8 \
    ja_JP.UTF-8 \
    it_IT.UTF-8 \
    uk_UA.UTF-8 \
    pl_PL.UTF-8 \
    da_DK.UTF-8 \
    fi_FI.UTF-8 \
    pt_PT.UTF-8 \
    zh_CN.UTF-8 \
    es_ES.UTF-8 \
    fr_FR.UTF-8
do
    if ! grep -qE "^${locale_name} UTF-8$" /etc/locale.gen; then
        echo "${locale_name} UTF-8" >> /etc/locale.gen
    fi
done
locale-gen

echo "--- Installing language packs and dictionaries (selected languages) ---"
install_many_if_available \
    language-pack-en \
    language-pack-en-base \
    hunspell-en-us \
    aspell-en \
    language-pack-de \
    language-pack-de-base \
    hunspell-de-de \
    aspell-de \
    language-pack-ja \
    language-pack-ja-base \
    hunspell-ja \
    language-pack-it \
    language-pack-it-base \
    hunspell-it \
    aspell-it \
    language-pack-uk \
    language-pack-uk-base \
    hunspell-uk \
    aspell-uk \
    language-pack-pl \
    language-pack-pl-base \
    hunspell-pl \
    aspell-pl \
    language-pack-da \
    language-pack-da-base \
    hunspell-da \
    aspell-da \
    language-pack-fi \
    language-pack-fi-base \
    hunspell-fi \
    aspell-fi \
    language-pack-pt \
    language-pack-pt-base \
    hunspell-pt-pt \
    aspell-pt \
    language-pack-zh-hans \
    language-pack-zh-hans-base \
    hunspell-zh-cn \
    language-pack-es \
    language-pack-es-base \
    hunspell-es \
    aspell-es \
    language-pack-fr \
    language-pack-fr-base \
    hunspell-fr \
    aspell-fr

echo ""
echo "=== Language support installation complete ==="
