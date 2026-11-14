#!/usr/bin/env bash
# Stops the installer's live session downloading the apps. Called by the Build ISO workflow at the end of the live image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

APP_INSTALL_TIMER="system-flatpak-setup.timer"

echo "Disabling ${APP_INSTALL_TIMER} in the live session"
systemctl disable "${APP_INSTALL_TIMER}"
