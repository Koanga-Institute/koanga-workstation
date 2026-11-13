#!/usr/bin/env bash
# Names the system Kōanga Workstation in os-release. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

OS_RELEASE="/usr/lib/os-release"
PRODUCT_NAME="Kōanga Workstation"

# shellcheck source=/dev/null
base_name="$(. "${OS_RELEASE}" && echo "${NAME} ${VERSION_ID}")"
pretty_name="${PRODUCT_NAME} (${base_name})"

echo "Setting PRETTY_NAME to ${pretty_name}"
sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=\"${pretty_name}\"|" "${OS_RELEASE}"
