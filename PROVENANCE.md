<!--
SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Provenance

Each row is a source ursa.nz did not write alone. The full licence texts are in `LICENSES/`. The image has the Fuji driver's licence at `/usr/share/licenses/fxlinuxprint/COPYING`.

| Source | Files | Licence | Taken |
| --- | --- | --- | --- |
| [AlmaLinux/atomic-respin-template](https://github.com/AlmaLinux/atomic-respin-template) at commit `6041267` | `Dockerfile`, `Makefile`, `.gitignore`, `atomic-desktop.pub`, `.github/`, and `build.sh`, `cleanup.sh`, `90-signing.sh` and `91-image-info.sh` in `files/scripts/` | GPL-3.0-only | 2026-11-14 |
| Kōanga's 2022 logo, from Kōanga's brand folder | `Koanga_Logo_2022_F6EEE8.svg` and `Koanga_Logo_2022_555725.svg` in `files/system/usr/share/pixmaps/` | CC-BY-NC-SA-4.0 outside Kōanga. Kōanga uses its logo without limit on its own network. | 2026-11-14 |
| Wallpapers ursa.nz made from Kōanga's logo and colours | `files/system/usr/share/backgrounds/koanga/*.png` | CC-BY-NC-SA-4.0 outside Kōanga. Kōanga uses its logo without limit on its own network. | 2026-11-14 |
| The ursa.nz Flatpak repo file at <https://software.ursa.nz/flatpak/ursa.flatpakrepo> | `files/system/etc/flatpak/remotes.d/ursa-nz.flatpakrepo` | GPL-3.0-or-later | 2026-11-14 |
| The ō mark ursa.nz drew for the top bar | `files/system/usr/share/icons/Koanga/scalable/apps/fedora-logo-icon.svg` | CC-BY-NC-SA-4.0 outside Kōanga. Kōanga uses it without limit on its own network. | 2026-11-14 |
| Chromium's logo, `chrome/app/theme/chromium/product_logo.svg` in [Chromium's source](https://chromium.googlesource.com/chromium/src/) | `files/system/usr/share/icons/Koanga/scalable/apps/io.github.ungoogled_software.ungoogled_chromium.svg` | BSD-3-Clause | 2026-11-14 |
| Fuji Xerox's fxlinuxprint 1.1.0, from Debian's source package `fxlinuxprint` 1.1.0+ds-4 on <https://snapshot.debian.org>. The build downloads it and checks its SHA-256. The repo stores none of it. | In the image, the three filters ending in `fx` in `/usr/lib/cups/filter/`, `fxlinuxprint.ppd` and the two `mimefx` files | GPL-2.0-or-later | Each build |

The template's repo has the GPL version 3 text and no "or later" grant, so its files stay GPL-3.0-only. A file ursa.nz changed credits both.
