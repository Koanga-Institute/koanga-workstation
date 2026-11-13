#!/usr/bin/env bash
# Removes the packages the image leaves out. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

REMOVED_PACKAGES=(
    firefox
    gnome-shell-extension-background-logo
    gnome-tour
)

echo "Removing ${REMOVED_PACKAGES[*]}"
dnf remove -y "${REMOVED_PACKAGES[@]}"
