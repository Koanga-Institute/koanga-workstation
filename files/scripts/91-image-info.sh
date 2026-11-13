#!/usr/bin/env bash
# Writes the image name to os-release as VARIANT_ID. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2025 The atomic-respin-template authors
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-only

set -xeuo pipefail

sed -i '/VARIANT_ID=/d;' /usr/lib/os-release
echo "VARIANT_ID=\"${IMAGE_NAME}\"" >> /usr/lib/os-release
