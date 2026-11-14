#!/usr/bin/env bash
# Opens the firewall to printer discovery, makes A4 the default paper and enables the units that look up .local names and add the Fuji. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

FIREWALL_ZONE="public"
CUPSD_CONF="/etc/cups/cupsd.conf"
DEFAULT_PAPER="A4"

echo "Allowing mdns in the ${FIREWALL_ZONE} zone"
firewall-offline-cmd --zone="${FIREWALL_ZONE}" --add-service=mdns

echo "Setting CUPS's default paper to ${DEFAULT_PAPER}"
sed -i '/^DefaultPaperSize/d' "${CUPSD_CONF}"
echo "DefaultPaperSize ${DEFAULT_PAPER}" >> "${CUPSD_CONF}"

echo "Enabling koanga-local-names.service and koanga-printers.service"
systemctl enable koanga-local-names.service koanga-printers.service
