#!/usr/bin/env bash
# Builds Fuji Xerox's GPL printer driver from Debian's source into the directory given. Called by the Dockerfile's fuji-driver stage.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

SNAPSHOT_URL="https://snapshot.debian.org/file"
SOURCE_SHA1="8ddc620099a1bed05b22096936662bd6ae94abbb"
SOURCE_SHA256="f7885403f8555c357c3ebaafed65a38878951897b8b97720b09203f69ab199ec"
PACKAGING_SHA1="a4159b2493ca8a7c6730f062d91777d31f092a31"
PACKAGING_SHA256="541501c7337e8239d47b7ad0e14668ba57f22b3d36ddbd991b40e97d3b27d763"

# Constraint: 0003 routes PDF through pdftopdf, which makes copies before the
# driver asks the printer for them. Kōanga's Fuji collates only without it.
DEBIAN_PATCHES=(
    0001-fix-typo-in-fxlinuxprint.c.patch
    0002-correct-install-path-for-.types-and-.convs-files.patch
    0004-fxlinuxprint-fix-ppd-loading-in-filter-and-buffer-ov.patch
    0005-fxlinuxprint-explicit-printer-models-in-ppd.patch
)

COPIES_PATCH="$(dirname "$0")/fxlinuxprint-copies.patch"

BUILD_PACKAGES=(gcc cups-devel patch)
FILTER_DIR="usr/lib/cups/filter"
MODEL_DIR="usr/share/cups/model/FujiXerox/en"
MIME_DIR="usr/share/cups/mime"
LICENCE_DIR="usr/share/licenses/fxlinuxprint"

# Downloads one archive from Debian's snapshot and unpacks it. Exits on a checksum mismatch.
fetch_archive() {
    local sha1="$1" sha256="$2" target_dir="$3"
    local archive
    archive="$(mktemp)"

    curl --fail --silent --show-error --location --output "${archive}" "${SNAPSHOT_URL}/${sha1}"
    echo "${sha256}  ${archive}" | sha256sum --check --quiet
    mkdir -p "${target_dir}"
    tar --extract --xz --file "${archive}" --directory "${target_dir}"
    rm "${archive}"
}

# Applies Debian's patches to the source tree, then the copy count patch.
apply_patches() {
    local source_dir="$1" patch_dir="$2"
    local patch_name

    for patch_name in "${DEBIAN_PATCHES[@]}"; do
        patch --directory "${source_dir}" --strip 1 --input "${patch_dir}/${patch_name}"
    done
    patch --directory "${source_dir}" --strip 1 --input "${COPIES_PATCH}"
}

# Compiles the three filters into the source tree.
build_filters() {
    local source_dir="$1"

    gcc -O2 -D__PS2PDF__ -o "${source_dir}/pstopdffx" "${source_dir}/fxlinuxprint.c" "${source_dir}/codec.c" -lcups
    gcc -O2 -o "${source_dir}/pdftopjlfx" "${source_dir}/fxlinuxprint.c" "${source_dir}/codec.c" -lcups
    gcc -O2 -o "${source_dir}/pdftopdffx" "${source_dir}/pdftopdffx.c"
}

# Lays the filters, the printer description, the MIME rules and the licence out under the output directory as they go under /.
install_driver() {
    local source_dir="$1" output_dir="$2"

    install -D --mode 0755 --target-directory "${output_dir}/${FILTER_DIR}" \
        "${source_dir}/pstopdffx" "${source_dir}/pdftopjlfx" "${source_dir}/pdftopdffx"
    install -D --mode 0644 --target-directory "${output_dir}/${MODEL_DIR}" "${source_dir}/fxlinuxprint.ppd"
    install -D --mode 0644 --target-directory "${output_dir}/${MIME_DIR}" \
        "${source_dir}/mimefx.types" "${source_dir}/mimefx.convs"
    install -D --mode 0644 --target-directory "${output_dir}/${LICENCE_DIR}" "${source_dir}/COPYING"
}

if [[ "$#" -ne 1 ]]; then
    echo "[build-fuji-driver] usage: build-fuji-driver.sh <output directory>" >&2
    exit 1
fi
output_dir="$1"
work_dir="$(mktemp --directory)"

echo "Installing ${BUILD_PACKAGES[*]}"
dnf install -y "${BUILD_PACKAGES[@]}"

echo "Fetching fxlinuxprint from ${SNAPSHOT_URL}"
fetch_archive "${SOURCE_SHA1}" "${SOURCE_SHA256}" "${work_dir}/source"
fetch_archive "${PACKAGING_SHA1}" "${PACKAGING_SHA256}" "${work_dir}/packaging"
source_dir="$(find "${work_dir}/source" -mindepth 1 -maxdepth 1 -type d)"

apply_patches "${source_dir}" "${work_dir}/packaging/debian/patches"
build_filters "${source_dir}"
install_driver "${source_dir}" "${output_dir}"
echo "Built the driver into ${output_dir}"
