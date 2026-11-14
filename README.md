<!--
SPDX-FileCopyrightText: 2026 ursa.nz <code@ursa.nz>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Kōanga Workstation

Kōanga Workstation is the desktop image for Kōanga's shared machines, built on AlmaLinux's atomic GNOME desktop.

## What a machine gets

A machine starts signed in to the Kōanga account. That account has no password and no admin rights, and its screen never locks. The sign-in screen signs it back in thirty seconds after anyone signs out. The admin account is made at install.

Each machine installs ungoogled Chromium, ONLYOFFICE, VLC and HandBrake from Flathub the first time it starts with internet, and Onym from the ursa.nz Flatpak repo, which is the remote `ursa-nz`. Chromium is the only browser, and its launcher shows Chromium's name and blue icon. GNOME Software keeps the apps up to date.

Chromium's Home button goes to koanga.org.nz and its address bar searches with DuckDuckGo, and both are locked. It has uBlock Origin and the Chromium Web Store add-on from its first start. It checks spelling against the Australian and British dictionaries.

The desktop shows Kōanga's wallpaper, Clay on Blush in the light style and Sage on Olive in the dark style. Dash to Dock keeps the dock on screen. The boot screen and the sign-in screen show Kōanga's logo, and the top bar shows its ō. The boot menu spells Kōanga with its macron from a machine's second start. Settings names the system Kōanga Workstation and shows the logo on its About page.

The keyboard is the Māori layout. Right Alt with a vowel types its macron.

Network printers show up on their own, and A4 is the default paper. Each machine adds Kōanga's Fuji ApeosPort at first start, with Collated on, and makes it the default printer. The queue has the name CUPS gives the Fuji on the network, so a print dialogue lists it once. The Fuji runs on Fuji Xerox's GPL driver, which the build compiles from Debian's source.

SSH takes keys and refuses passwords. The admin keys in the image sign in to any admin account. The Cockpit web console is off.

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

## Set up once

### 1. Make the image public

GitHub makes a new image private, and a private image stops every update. A machine downloads updates without signing in. Open the [package's settings](https://github.com/orgs/Koanga-Institute/packages/container/koanga-workstation/settings), choose Change visibility, then Public. Where GitHub says the org has disabled the setting, tick Public under Package creation in the [org's package settings](https://github.com/organizations/Koanga-Institute/settings/packages) first.

### 2. Store the signing key

GitHub signs each image with the key in the repo's `SIGNING_SECRET` secret. A machine refuses an image without that signature. Keep the only other copy of the key, `cosign.key`, in a password manager. Git ignores that filename.

## Install a machine

The install wipes the machine's disk. A fresh install with its apps takes 12 GB.

### 1. Build the installer

The newest image is inside the installer, so the install needs no internet.

```sh
gh workflow run build-iso.yml --repo Koanga-Institute/koanga-workstation
```

Download the ISO when the run ends. GitHub keeps it for seven days.

```sh
gh run download --repo Koanga-Institute/koanga-workstation --name koanga-workstation-amd64
sha256sum --check koanga-workstation-amd64.iso-CHECKSUM
```

### 2. Write it to a USB stick

`lsblk` lists the stick's device. This wipes the stick.

```sh
sudo dd if=koanga-workstation-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

### 3. Run the installer

1. Start the machine from the stick and choose Start koanga-workstation Live.
2. Choose Install AlmaLinux, then a language.
3. Open Installation Destination and tick the disk. Where the disk has a system on it, tick Free up space, choose Done, then Delete all and Reclaim space.
4. Open User Creation. Name the admin account and set its password. Leave Add administrative privileges ticked.
5. Choose Begin Installation, and Finish Installation when it ends.
6. Power off from the menu at the top right. Pull the stick out and start the machine.

### 4. Check the machine

On a wired network the apps appear within ten minutes of the first start. On Wi-Fi, join the network, then start the app install from Terminal.

```sh
su - admin
sudo systemctl start system-flatpak-setup.service
```

Then run the checks as the admin account.

```sh
sudo bootc status
flatpak list --system --app
lpstat -v
systemctl --failed
```

`bootc status` shows the image `ghcr.io/koanga-institute/koanga-workstation:latest`. Flatpak lists five apps. `lpstat` lists the Fuji. No unit has failed.

## Look after a machine

Run these as the admin account, over SSH or after `su - admin` in Terminal.

### Update

A machine looks for a new image an hour after it starts and every eight hours after that. It downloads the image and starts on it at its next restart. This updates one now.

```sh
sudo bootc upgrade
sudo systemctl reboot
```

### Roll back

A machine keeps the system it ran before its last update. This starts it on that system again.

```sh
sudo bootc rollback
sudo systemctl reboot
```

### Change the admin keys

Edit `files/system/usr/share/koanga-workstation/ssh/admin-keys` and push. Each machine takes the new keys once it has updated and restarted.

### Update Chromium's add-ons

Ungoogled Chromium has no add-on updater. The Chromium Web Store add-on shows a badge when a newer one is out, and anyone can install it from there. To put a newer one in the image, change its version and SHA-256 in `files/scripts/55-chromium.sh` and push.

### Add a USB label printer

CUPS's Zebra ZPL driver is in the image. Plug the printer in, find its address, then add it.

```sh
sudo lpinfo -v | grep usb
sudo lpadmin -p Labels -E -v 'usb://...' -m drv:///sample.drv/zebra.ppd
```

## Where each setting is

| To change | Edit |
| --- | --- |
| The apps a machine installs from Flathub | `files/system/etc/flatpak/default-flatpaks/system/install` |
| The apps a machine installs from ursa.nz | `files/system/etc/flatpak/default-flatpaks/system/install-ursa-nz` |
| The default browser | `files/system/etc/xdg/mimeapps.list` |
| The default wallpaper, the dock, the keyboard, the icon theme and the screen lock | `files/system/etc/dconf/db/local.d/00-koanga-workstation` |
| The wallpapers on offer | `files/system/usr/share/backgrounds/koanga/`, one `Koanga_<colourway>_<width>x<height>.png` for each screen shape |
| The sign-in logo | `files/system/etc/dconf/db/gdm.d/00-koanga-workstation` |
| The boot screen | `files/system/usr/share/plymouth/themes/koanga/koanga.plymouth` and `files/scripts/30-branding.sh` |
| An app's icon | `files/system/usr/share/icons/Koanga/scalable/apps/`, one file named for the app's ID |
| The ō logo | `files/system/usr/share/icons/Koanga/scalable/apps/fedora-logo-icon.svg`. The installer's session shows it on a disc, which `files/scripts/iso/prepare-live-session.sh` draws. |
| Chromium's launcher name | `files/system/usr/libexec/koanga-workstation/rename-chromium-launcher` |
| Chromium's home page, search engine and spell-check languages | `files/system/usr/share/koanga-workstation/chromium/policy/policies/managed/koanga.json` |
| Chromium's add-ons, their versions and its dictionaries | `files/scripts/55-chromium.sh` |
| Chromium's start-up flags | `files/system/usr/share/koanga-workstation/chromium/chromium-flags.conf` |
| The boot menu's font | `files/system/usr/share/koanga-workstation/grub/user.cfg` |
| Automatic sign-in and its delay after a sign-out | `files/system/etc/gdm/custom.conf` |
| The Kōanga account and its keyring | `files/system/usr/libexec/koanga-workstation/create-koanga-account` |
| The Fuji's queue and its options | `files/system/usr/libexec/koanga-workstation/add-fuji-printer` |
| The Fuji's driver | `files/scripts/stages/build-fuji-driver.sh` |
| Printer discovery and the default paper | `files/scripts/50-printers.sh` and `files/system/etc/papersize` |
| Lookups of `.local` names | `files/system/usr/libexec/koanga-workstation/enable-local-names` |
| SSH | `files/system/etc/ssh/sshd_config.d/10-keys-only.conf` and `20-admin-keys.conf` beside it |
| The admin keys | `files/system/usr/share/koanga-workstation/ssh/admin-keys` |
| The web console | `files/scripts/60-remote-access.sh` |
| The packages removed and added | `files/scripts/10-packages.sh` |
| The name and the logo in Settings | `files/scripts/30-branding.sh` |

## Checks

```sh
shellcheck files/scripts/*.sh files/scripts/stages/*.sh files/scripts/iso/*.sh files/system/usr/libexec/koanga-workstation/*
reuse lint
ruru . --skip licence.copyright,licence.identifier
```

The two skipped rules expect ursa.nz on every file. `PROVENANCE.md` lists the files that credit someone else.

## Licences

The code is GPL-3.0-or-later. The files from AlmaLinux's template are GPL-3.0-only. The Fuji driver in the image is GPL-2.0-or-later, and `PROVENANCE.md` says where its source is. Chromium's logo is BSD-3-Clause. Kōanga's logo and the wallpapers are CC-BY-NC-SA-4.0 outside Kōanga, and Kōanga uses them without limit on its own network.

## Caveats

Every step above ran in a virtual machine with UEFI firmware. A real machine, a Wi-Fi join and both label printers are untried. The installer also starts on BIOS firmware, and an install there is untried.

The printers were tried on Kōanga's network from a container of the image. Both Brothers set up without a driver, and the Fuji printed two collated copies.

The Fuji's queue finds the printer by its name on Kōanga's network. It prints PDFs, which is what apps send, and fails on PostScript and plain text files.

The firewall lets in SSH on port 22 and printer discovery on port 5353.

Chromium flags te reo Māori words as misspelt, since neither dictionary has them. Anyone using the Kōanga account can remove an add-on, and it stays removed.

Roll back first when an update goes wrong. A reinstall is the last resort, and it wipes the files in the Kōanga account.
