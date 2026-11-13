#!/usr/bin/env bash
# Clears the package cache, /var and /boot. Called by build.sh at the end of the image build.
# SPDX-FileCopyrightText: 2025 The atomic-respin-template authors
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-only

set -xeuo pipefail

# Image cleanup
# Specifically called by build.sh

# Image-layer cleanup
shopt -s extglob

dnf clean all

# shellcheck disable=SC2114
rm -rf /.gitkeep /var /boot
mkdir -p /boot /var

# Make /usr/local writeable, unless the base image already did it
if [[ ! -L /usr/local ]]; then
    mv /usr/local /var/usrlocal
    ln -s /var/usrlocal /usr/local
fi
