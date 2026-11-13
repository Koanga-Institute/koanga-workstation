#!/bin/bash
# Copies the system files into the image and runs each numbered script. Called by the Dockerfile.
# SPDX-FileCopyrightText: 2025 The atomic-respin-template authors
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-only

set -ouex pipefail

CONTEXT_PATH="$(realpath "$(dirname "$0")/..")" # should return /ctx
BUILD_SCRIPTS_PATH="$(realpath "$(dirname "$0")")"

printf "::group:: === Copying files ===\n"
cp -avf "${CONTEXT_PATH}/system_files/." /
printf "::endgroup::\n"

for script in $(find "${BUILD_SCRIPTS_PATH}" -maxdepth 1 -iname "*-*.sh" -type f | sort --sort=human-numeric); do
  printf "::group:: === %s ===\n" "$(basename "$script")"
  "$(realpath "$script")"
  printf "::endgroup::\n"
done

printf "::group:: === Image Cleanup ===\n"
# Ensure these get run at the _end_ of the build no matter what
"${BUILD_SCRIPTS_PATH}/cleanup.sh"
printf "::endgroup::\n"
