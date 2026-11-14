#!/usr/bin/env bash
# Stops the installer's live session downloading the apps and gives it a logo that shows on light and dark. Called by the Build ISO workflow at the end of the live image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

APP_INSTALL_TIMER="system-flatpak-setup.timer"
LOGO_ICON="/usr/share/icons/Koanga/scalable/apps/fedora-logo-icon.svg"
MARK_FILL="#fff"
MARK_CENTRE=1024
BADGE_MARK_FILL="#f6eee8"
BADGE_FILL="#914e3e"
BADGE_SIZE=128
BADGE_RADIUS=56
BADGE_MARK_SCALE="0.0336"

# Redraws the logo icon as the ō on a padded disc.
draw_logo_badge() {
    local mark_path badge_centre

    mark_path="$(grep '<path' "${LOGO_ICON}" | sed "s/fill=\"${MARK_FILL}\"/fill=\"${BADGE_MARK_FILL}\"/")"
    badge_centre="$(( BADGE_SIZE / 2 ))"

    echo "Drawing the logo badge at ${LOGO_ICON}"
    cat > "${LOGO_ICON}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg width="${BADGE_SIZE}" height="${BADGE_SIZE}" viewBox="0 0 ${BADGE_SIZE} ${BADGE_SIZE}" xmlns="http://www.w3.org/2000/svg">
 <circle cx="${badge_centre}" cy="${badge_centre}" r="${BADGE_RADIUS}" fill="${BADGE_FILL}"/>
 <g transform="translate(${badge_centre} ${badge_centre}) scale(${BADGE_MARK_SCALE}) translate(-${MARK_CENTRE} -${MARK_CENTRE})">
${mark_path}
 </g>
</svg>
EOF
}

echo "Disabling ${APP_INSTALL_TIMER} in the live session"
systemctl disable "${APP_INSTALL_TIMER}"

draw_logo_badge
