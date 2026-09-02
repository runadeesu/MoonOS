#!/bin/sh
set -eu

PROJECT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$PROJECT_DIR"

if [ "$(id -u)" -ne 0 ]; then
  echo 'ISO assembly uses chroot and must run with sudo.' >&2
  exit 1
fi

for command_name in lb xorriso mksquashfs; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing build tool: $command_name" >&2
    echo 'Run: sudo ./scripts/install-build-deps.sh' >&2
    exit 1
  fi
done

mkdir -p dist
lb clean --purge || true
lb config
lb build 2>&1 | tee build.log

iso_path="$(find . -maxdepth 1 -type f \( -name '*.hybrid.iso' -o -name 'moonos-*.iso' \) | head -n 1)"
if [ -z "$iso_path" ]; then
  echo 'Build completed without producing an ISO.' >&2
  exit 1
fi

output='dist/MoonOS-0.1-amd64.iso'
mv "$iso_path" "$output"
sha256sum "$output" > "$output.sha256"
echo "MoonOS ISO ready: $output"
