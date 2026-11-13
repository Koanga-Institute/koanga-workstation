#!/usr/bin/env bash
# Writes a background file for each wallpaper colourway and lists them for Settings. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

WALLPAPER_DIR="/usr/share/backgrounds/koanga"
SETTINGS_LIST="/usr/share/gnome-background-properties/koanga.xml"

# Prints each colourway that has a picture in WALLPAPER_DIR, one a line.
list_colourways() {
    find "${WALLPAPER_DIR}" -maxdepth 1 -name 'Koanga_*_*x*.png' -printf '%f\n' \
        | sed -E 's/^Koanga_(.+)_[0-9]+x[0-9]+\.png$/\1/' \
        | sort -u
}

# Prints the background file that picks a colourway's picture by screen shape.
print_background_file() {
    local colourway="$1"
    local picture size

    echo "<background>"
    echo "  <static>"
    echo "    <duration>86400.0</duration>"
    echo "    <file>"
    for picture in "${WALLPAPER_DIR}/Koanga_${colourway}_"*.png; do
        size="$(basename "${picture}" .png)"
        size="${size##*_}"
        echo "      <size width=\"${size%x*}\" height=\"${size#*x}\">${picture}</size>"
    done
    echo "    </file>"
    echo "  </static>"
    echo "</background>"
}

# Prints the list Settings reads its wallpaper choices from.
print_settings_list() {
    local colourway

    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">'
    echo "<wallpapers>"
    for colourway in "$@"; do
        echo '  <wallpaper deleted="false">'
        echo "    <name>Kōanga ${colourway//-/ }</name>"
        echo "    <filename>${WALLPAPER_DIR}/Koanga_${colourway}.xml</filename>"
        echo "    <options>zoom</options>"
        echo "  </wallpaper>"
    done
    echo "</wallpapers>"
}

mapfile -t colourways < <(list_colourways)
if [[ "${#colourways[@]}" -eq 0 ]]; then
    echo "[20-wallpapers] no pictures in ${WALLPAPER_DIR}" >&2
    exit 1
fi

for colourway in "${colourways[@]}"; do
    echo "Writing the background file for ${colourway}"
    print_background_file "${colourway}" > "${WALLPAPER_DIR}/Koanga_${colourway}.xml"
done

echo "Listing ${#colourways[@]} wallpapers for Settings"
print_settings_list "${colourways[@]}" > "${SETTINGS_LIST}"
