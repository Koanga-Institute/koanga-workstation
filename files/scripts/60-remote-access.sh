#!/usr/bin/env bash
# Turns off the Cockpit web console and closes its port in the firewall. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

FIREWALL_ZONE="public"
WEB_CONSOLE_SOCKET="cockpit.socket"
WEB_CONSOLE_SERVICE="cockpit"

echo "Disabling ${WEB_CONSOLE_SOCKET}"
systemctl disable "${WEB_CONSOLE_SOCKET}"

echo "Removing ${WEB_CONSOLE_SERVICE} from the ${FIREWALL_ZONE} zone"
firewall-offline-cmd --zone="${FIREWALL_ZONE}" --remove-service-from-zone="${WEB_CONSOLE_SERVICE}"
