#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo 'Run this script with sudo.' >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo 'MoonOS ISO builds currently require Debian or Ubuntu (WSL is supported).' >&2
  exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  live-build debootstrap squashfs-tools xorriso isolinux syslinux-common \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools rsync ca-certificates
