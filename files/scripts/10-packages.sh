#!/usr/bin/env bash
# Removes the packages the image leaves out and installs the ones it adds. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

REMOVED_PACKAGES=(
    firefox
    gnome-shell-extension-background-logo
    gnome-tour
)
ADDED_PACKAGES=(
    gnome-shell-extension-dash-to-dock
    nss-mdns
)

echo "Removing ${REMOVED_PACKAGES[*]}"
dnf remove -y "${REMOVED_PACKAGES[@]}"

echo "Installing ${ADDED_PACKAGES[*]}"
dnf install -y "${ADDED_PACKAGES[@]}"
