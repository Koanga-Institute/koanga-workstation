#!/usr/bin/env bash
# Downloads Chromium's spell-check dictionaries and its two add-ons, and writes the files that install the add-ons. Called by build.sh during the image build.
# SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

CHROMIUM_DIR="/usr/share/koanga-workstation/chromium"
LICENCE_DIR="/usr/share/licenses"
# The folder Flatpak mounts the add-ons at inside Chromium's sandbox.
SANDBOX_ADDON_DIR="/app/chromium/extensions/koanga"

# Constraint: Chromium 157 loads dictionaries named -10-2 only. A newer Chromium that asks for another
# version finds none, and spell check stops until this commit and the names below move with it.
DICTIONARY_COMMIT="00f6e69c905b30fdf701cdcef6a517582d7e0028"
DICTIONARY_SOURCE="https://chromium.googlesource.com/chromium/deps/hunspell_dictionaries/+/${DICTIONARY_COMMIT}"

WEB_STORE_ID="ocaahdebbfolfmndjeplogmgcagdmblk"
WEB_STORE_VERSION="1.5.5.4"
WEB_STORE_SOURCE="https://github.com/NeverDecaf/chromium-web-store/releases/download/v${WEB_STORE_VERSION}/Chromium.Web.Store.crx"
WEB_STORE_SHA256="63c075b4a25b11af2c536dad191946e8d9547f92d5b6c257b2ce4138d2996f32"
WEB_STORE_LICENCE="https://raw.githubusercontent.com/NeverDecaf/chromium-web-store/v${WEB_STORE_VERSION}/LICENSE"
WEB_STORE_LICENCE_SHA256="0d0e90c6c9823b67bbc433085a1ad901dc3b736b2c3498b0443b1ad5565c2de6"

UBLOCK_ID="fkgkibajhfbepljeaefdnfnegdcjomkh"
UBLOCK_VERSION="1.76.2"
UBLOCK_SOURCE="https://github.com/gorhill/uBlock/releases/download/${UBLOCK_VERSION}/uBlock0_${UBLOCK_VERSION}.chromium.crx"
UBLOCK_SHA256="a5c137a570920c73b9a5d0f4d4778940afd45a5d495310c889035e695d165ad9"
UBLOCK_LICENCE="https://raw.githubusercontent.com/gorhill/uBlock/${UBLOCK_VERSION}/LICENSE.txt"
UBLOCK_LICENCE_SHA256="e73d33841f942fa73aa5a63d4a6399cc39a29564db1dbca0915485842fcb236d"

# Downloads a file and checks its SHA-256.
fetch_checked() {
    local source="$1" sha256="$2" target="$3"

    echo "Downloading ${target}"
    mkdir -p "$(dirname "${target}")"
    curl --fail --silent --show-error --location --output "${target}" "${source}"
    echo "${sha256}  ${target}" | sha256sum --check --quiet
}

# Downloads one file of Chromium's dictionary source, which arrives in base64, and checks its SHA-256.
fetch_dictionary_file() {
    local name="$1" sha256="$2" target_dir="$3"

    echo "Downloading ${target_dir}/${name}"
    mkdir -p "${target_dir}"
    curl --fail --silent --show-error --location "${DICTIONARY_SOURCE}/${name}?format=TEXT" \
        | base64 --decode > "${target_dir}/${name}"
    echo "${sha256}  ${target_dir}/${name}" | sha256sum --check --quiet
}

# Downloads an add-on and writes the file that tells Chromium to install it.
add_addon() {
    local id="$1" version="$2" source="$3" sha256="$4"

    fetch_checked "${source}" "${sha256}" "${CHROMIUM_DIR}/extension/crx/${id}.crx"
    mkdir -p "${CHROMIUM_DIR}/extension/extensions"
    cat > "${CHROMIUM_DIR}/extension/extensions/${id}.json" <<EOF
{
  "external_crx": "${SANDBOX_ADDON_DIR}/crx/${id}.crx",
  "external_version": "${version}"
}
EOF
}

fetch_dictionary_file "en-AU-10-2.bdic" "13427b9828773291cde00ba266a58fd5110ba6f1d4b29ed86b49f4b3afdf0a39" "${CHROMIUM_DIR}/dictionaries"
fetch_dictionary_file "en-GB-10-2.bdic" "e014c23d2215f093205343b9b8805e17c8d8e115d314d93fd5ba51eadf05cff2" "${CHROMIUM_DIR}/dictionaries"
fetch_dictionary_file "README_en_AU.txt" "f0897dcfdf058bcfc93fbc8e7e1b5da4c27ae9e175ee3a9242e887f02eb84a8b" "${LICENCE_DIR}/chromium-dictionaries"
fetch_dictionary_file "README_en_GB.txt" "0bcf1616b29dee3fbcbef1428b0c3d4d77f6a36cc88b9e130ee65e5382899029" "${LICENCE_DIR}/chromium-dictionaries"

add_addon "${WEB_STORE_ID}" "${WEB_STORE_VERSION}" "${WEB_STORE_SOURCE}" "${WEB_STORE_SHA256}"
fetch_checked "${WEB_STORE_LICENCE}" "${WEB_STORE_LICENCE_SHA256}" "${LICENCE_DIR}/chromium-web-store/LICENSE"

add_addon "${UBLOCK_ID}" "${UBLOCK_VERSION}" "${UBLOCK_SOURCE}" "${UBLOCK_SHA256}"
fetch_checked "${UBLOCK_LICENCE}" "${UBLOCK_LICENCE_SHA256}" "${LICENCE_DIR}/ublock-origin/LICENSE.txt"
