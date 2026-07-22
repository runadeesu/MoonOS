#!/usr/bin/env bash
# Boots the Moon OS disk images in QEMU.
# Usage: ./run-qemu.sh [bios|uefi]  (default: bios)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-bios}"

if [[ "${MODE}" == "bios" ]]; then
  exec qemu-system-x86_64 \
    -drive format=raw,file="${REPO_ROOT}/build/images/moon-os-bios.img" \
    -serial stdio \
    -m 256M
elif [[ "${MODE}" == "uefi" ]]; then
  OVMF_PATH="${OVMF_PATH:-/usr/share/ovmf/OVMF.fd}"
  exec qemu-system-x86_64 \
    -bios "${OVMF_PATH}" \
    -drive format=raw,file="${REPO_ROOT}/build/images/moon-os-uefi.img" \
    -serial stdio \
    -m 256M
else
  echo "Usage: $0 [bios|uefi]" >&2
  exit 1
fi
