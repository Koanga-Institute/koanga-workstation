#!/usr/bin/env bash
# Enables the units for the Kōanga account and Chromium's launcher name, and compiles the desktop defaults. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

SKEL_SETUP_DONE="/etc/skel/.config/gnome-initial-setup-done"

echo "Enabling koanga-account.service and the Chromium launcher units"
systemctl enable koanga-account.service koanga-chromium-launcher.service koanga-chromium-launcher.path

echo "Marking the first sign-in setup done for new accounts"
mkdir -p "$(dirname "${SKEL_SETUP_DONE}")"
echo "yes" > "${SKEL_SETUP_DONE}"

echo "Compiling the dconf databases"
dconf update
