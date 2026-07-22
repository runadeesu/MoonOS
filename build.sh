#!/usr/bin/env bash
# Builds the Moon OS kernel and packages it into bootable BIOS/UEFI disk images.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${REPO_ROOT}/build/images"

echo "==> Building moon-kernel (target: x86_64-unknown-none)"
(cd "${REPO_ROOT}/kernel" && cargo build --release --target x86_64-unknown-none)

echo "==> Building moon-image-builder"
(cd "${REPO_ROOT}/tools/image-builder" && cargo +nightly build --release)

echo "==> Packaging disk images into ${OUT_DIR}"
"${REPO_ROOT}/tools/image-builder/target/release/moon-image-builder" \
  "${REPO_ROOT}/kernel/target/x86_64-unknown-none/release/moon-kernel" \
  "${OUT_DIR}"

echo "==> Done. Images:"
ls -la "${OUT_DIR}"
