#!/usr/bin/env bash
# Opens the firewall to printer discovery, resolves .local names, makes A4 the default paper and enables the unit that adds the Fuji. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

FIREWALL_ZONE="public"
CUPSD_CONF="/etc/cups/cupsd.conf"
DEFAULT_PAPER="A4"
MDNS_FEATURE="with-mdns4"
NSSWITCH_CONF="/etc/nsswitch.conf"

echo "Allowing mdns in the ${FIREWALL_ZONE} zone"
firewall-offline-cmd --zone="${FIREWALL_ZONE}" --add-service=mdns

echo "Resolving .local names through ${MDNS_FEATURE}"
authselect enable-feature "${MDNS_FEATURE}"
grep -q "^hosts:.*mdns4_minimal" "${NSSWITCH_CONF}" || {
    echo "[printers] ${NSSWITCH_CONF} has no mdns4_minimal on its hosts line" >&2
    exit 1
}

echo "Setting CUPS's default paper to ${DEFAULT_PAPER}"
sed -i '/^DefaultPaperSize/d' "${CUPSD_CONF}"
echo "DefaultPaperSize ${DEFAULT_PAPER}" >> "${CUPSD_CONF}"

echo "Enabling koanga-printers.service"
systemctl enable koanga-printers.service
