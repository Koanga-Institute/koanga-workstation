#!/usr/bin/env bash
# Names the system Kōanga Workstation and puts Kōanga's logo on the boot screen and the About page. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

OS_RELEASE="/usr/lib/os-release"
PRODUCT_NAME="Kōanga Workstation"
BOOT_THEME_DIR="/usr/share/plymouth/themes/koanga"
SPINNER_THEME_DIR="/usr/share/plymouth/themes/spinner"
LOGO_FOR_DARK="/usr/share/pixmaps/Koanga_Logo_2022_F6EEE8.svg"
LOGO_FOR_LIGHT="/usr/share/pixmaps/Koanga_Logo_2022_555725.svg"
BOOT_LOGO_WIDTH=300
ABOUT_LOGO_LIGHT="/usr/share/pixmaps/fedora-logo.png"
ABOUT_LOGO_DARK="/usr/share/pixmaps/system-logo-white.png"
ABOUT_LOGO_HEIGHT=160

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
        --output "${BOOT_THEME_DIR}/watermark.png" "${LOGO_FOR_DARK}"
}

# Renders Kōanga's logo over the two pictures Settings draws on its About page.
render_about_logos() {
    echo "Rendering the About page's logos"
    rsvg-convert --height "${ABOUT_LOGO_HEIGHT}" --keep-aspect-ratio \
        --output "${ABOUT_LOGO_LIGHT}" "${LOGO_FOR_LIGHT}"
    rsvg-convert --height "${ABOUT_LOGO_HEIGHT}" --keep-aspect-ratio \
        --output "${ABOUT_LOGO_DARK}" "${LOGO_FOR_DARK}"
}

# Rebuilds the initramfs, which holds the boot theme.
rebuild_initramfs() {
    local kernel_version
    kernel_version="$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n 1)"

    echo "Rebuilding the initramfs for ${kernel_version}"
    dracut --force "/usr/lib/modules/${kernel_version}/initramfs.img" "${kernel_version}"
}

name_system
render_about_logos
build_boot_theme
rebuild_initramfs
