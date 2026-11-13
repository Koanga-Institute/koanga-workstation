<!--
SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Kōanga Workstation

Kōanga Workstation is the desktop image for Kōanga's shared machines, built on AlmaLinux's atomic GNOME desktop.

## What a machine gets

A machine starts signed in to the Kōanga account. That account has no password and no admin rights, and its screen never locks. The sign-in screen signs it back in thirty seconds after anyone signs out. The admin account is made at install.

Each machine installs ungoogled Chromium, ONLYOFFICE, VLC and HandBrake from Flathub the first time it starts with internet, and Onym from the ursa.nz Flatpak repo, which is the remote `ursa-nz`. Chromium is the only browser, and it wears Chromium's blue icon.

The desktop shows Kōanga's wallpaper, Clay on Blush in the light style and Sage on Olive in the dark style. Dash to Dock keeps the dock on screen. The boot screen and the sign-in screen show Kōanga's logo, and the top bar shows its ō. Settings names the system Kōanga Workstation.

The keyboard is the Māori layout. Right Alt with a vowel types its macron.

Network printers show up on their own, and A4 is the default paper. Each machine adds Kōanga's Fuji ApeosPort at first start, with Collated on, and makes it the default printer. The Fuji runs on Fuji Xerox's GPL driver, which the build compiles from Debian's source.

SSH takes keys and refuses passwords.

## Build

The build needs Podman and `make`. `make image` runs Podman under `sudo` and tags the image `localhost/koanga-workstation`.

```sh
make image
```

Podman also builds it without root.

```sh
podman build --security-opt=label=disable --cap-add=all --device /dev/fuse \
    --build-arg IMAGE_NAME=koanga-workstation --build-arg IMAGE_REGISTRY=localhost \
    --tag localhost/koanga-workstation:trial .
```

The build copies `files/system/` onto the image's root, then runs the numbered scripts in `files/scripts/` in order. A separate stage runs `files/scripts/stages/build-fuji-driver.sh`, so its compiler stays out of the image. The `Dockerfile` pins AlmaLinux's base image by digest.

## Where each setting is

| To change | Edit |
| --- | --- |
| The apps a machine installs | `files/system/etc/flatpak/default-flatpaks/system/install` |
| The default browser | `files/system/etc/xdg/mimeapps.list` |
| The default wallpaper, the dock, the keyboard, the icon theme and the screen lock | `files/system/etc/dconf/db/local.d/00-koanga-workstation` |
| The wallpapers on offer | `files/system/usr/share/backgrounds/koanga/`, one `Koanga_<colourway>_<width>x<height>.png` for each screen shape |
| The sign-in logo | `files/system/etc/dconf/db/gdm.d/00-koanga-workstation` |
| The boot screen | `files/system/usr/share/plymouth/themes/koanga/koanga.plymouth` and `files/scripts/30-branding.sh` |
| An app's icon or the top bar's logo | `files/system/usr/share/icons/Koanga/`, one file named for the app's ID. GNOME asks for the top bar's logo as `fedora-logo-icon`. |
| Automatic sign-in and its delay after a sign-out | `files/system/etc/gdm/custom.conf` |
| The Kōanga account and its keyring | `files/system/usr/libexec/koanga-workstation/create-koanga-account` |
| The Fuji's queue and its options | `files/system/usr/libexec/koanga-workstation/add-fuji-printer` |
| The Fuji's driver | `files/scripts/stages/build-fuji-driver.sh` |
| Printer discovery and the default paper | `files/scripts/50-printers.sh` and `files/system/etc/papersize` |
| SSH | `files/system/etc/ssh/sshd_config.d/10-keys-only.conf` |
| The packages removed and added | `files/scripts/10-packages.sh` |
| The name in Settings | `files/scripts/30-branding.sh` |

## Checks

```sh
shellcheck files/scripts/*.sh files/scripts/stages/*.sh files/system/usr/libexec/koanga-workstation/*
reuse lint
ruru . --skip licence.copyright,licence.identifier
```

The two skipped rules expect ursa.nz on every file. `PROVENANCE.md` lists the files that credit someone else.

## Licences

The code is GPL-3.0-or-later. The files from AlmaLinux's template are GPL-3.0-only. The Fuji driver in the image is GPL-2.0-or-later, and `PROVENANCE.md` says where its source is. Chromium's logo is BSD-3-Clause. Kōanga's logo and the wallpapers are CC-BY-NC-SA-4.0 outside Kōanga, and Kōanga uses them without limit on its own network.
