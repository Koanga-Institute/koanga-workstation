#!/usr/bin/env bash
# Names the system Kōanga Workstation and puts Kōanga's logo on the boot screen. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

OS_RELEASE="/usr/lib/os-release"
PRODUCT_NAME="Kōanga Workstation"
BOOT_THEME_DIR="/usr/share/plymouth/themes/koanga"
SPINNER_THEME_DIR="/usr/share/plymouth/themes/spinner"
BOOT_LOGO_SOURCE="/usr/share/pixmaps/Koanga_Logo_2022_F6EEE8.svg"
BOOT_LOGO_WIDTH=300

# Sets the name Settings and the boot menu show.
name_system() {
    local base_name pretty_name

    # shellcheck source=/dev/null
    base_name="$(. "${OS_RELEASE}" && echo "${NAME} ${VERSION_ID}")"
    pretty_name="${PRODUCT_NAME} (${base_name})"

    echo "Setting PRETTY_NAME to ${pretty_name}"
    sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=\"${pretty_name}\"|" "${OS_RELEASE}"
}

# Copies the spinner's pictures into the boot theme and renders Kōanga's logo as its watermark.
build_boot_theme() {
    echo "Building the boot theme in ${BOOT_THEME_DIR}"
    find "${SPINNER_THEME_DIR}" -maxdepth 1 -name '*.png' ! -name 'watermark.png' \
        -exec cp --target-directory "${BOOT_THEME_DIR}" {} +
    rsvg-convert --width "${BOOT_LOGO_WIDTH}" --keep-aspect-ratio \
        --output "${BOOT_THEME_DIR}/watermark.png" "${BOOT_LOGO_SOURCE}"
}

# Rebuilds the initramfs, which holds the boot theme.
rebuild_initramfs() {
    local kernel_version
    kernel_version="$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n 1)"

    echo "Rebuilding the initramfs for ${kernel_version}"
    dracut --force "/usr/lib/modules/${kernel_version}/initramfs.img" "${kernel_version}"
}

name_system
build_boot_theme
rebuild_initramfs
