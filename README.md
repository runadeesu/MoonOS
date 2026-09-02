# MoonOS

MoonOS is a real, bootable gaming-focused operating system for 64-bit PCs. It is
built as a Debian-based live ISO: the Linux kernel, bootloader, root filesystem,
desktop session, hardware support, and MoonOS-specific tools are assembled into
one image that can boot from a USB drive.

This repository is the **MoonOS 0.1 Core** starting point. It is not a web mockup.

## What 0.1 includes

- BIOS and UEFI boot support through Debian Live
- XFCE desktop with MoonOS branding
- NetworkManager, PipeWire audio, Mesa/Vulkan and firmware packages
- Steam installer, Wine, GameMode, MangoHud and Flatpak
- MoonOS Welcome and a safe performance-mode helper
- Reproducible ISO configuration and an automated GitHub Actions build

The first release focuses on booting reliably. Android APK support, a graphical
installer, the Moon launcher/store and automatic update channels belong to later
milestones.

## Build on a Windows PC (recommended)

1. Enable WSL and install Ubuntu:

   ```powershell
   wsl --install -d Ubuntu
   ```

2. Open Ubuntu, copy or clone this project into the Linux filesystem, then run:

   ```bash
   cd MoonOS
   sudo ./scripts/install-build-deps.sh
   sudo ./scripts/build.sh
   ```

3. The finished image will be `dist/MoonOS-0.1-amd64.iso`.

You can also open the repository's **Actions** tab and run **Build MoonOS ISO**.
The resulting ISO will be downloadable as a workflow artifact.

## Test without installing

Use a virtual machine such as VirtualBox and boot it from the ISO. For a real PC,
write the ISO to a spare USB drive and choose that drive in the firmware boot
menu. Back up important files before installing or repartitioning any disk.

## Build targets

```bash
make deps       # install build dependencies (Debian/Ubuntu)
make iso        # build the ISO
make verify     # inspect the generated ISO and checksums
make clean      # remove generated live-build state
make distclean  # also remove dist/
```

## Roadmap

1. **0.1 Core** — bootable live ISO and desktop
2. **0.2 Install** — graphical disk installer and recovery mode
3. **0.3 Game** — controller-first launcher and per-game profiles
4. **0.4 EXE** — one-click Windows game compatibility profiles
5. **0.5 APK** — sandboxed Android runtime and app installer
6. **1.0** — signed updates, hardware testing and stable release

## Licensing

MoonOS-specific source in this repository is released under GPL-3.0-or-later.
Packages assembled into the ISO retain their own upstream licenses.
