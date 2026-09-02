#!/bin/sh
set -eu

PROJECT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$PROJECT_DIR"

iso='dist/MoonOS-0.1-amd64.iso'
[ -f "$iso" ] || { echo "Missing $iso. Run make iso first." >&2; exit 1; }

sha256sum -c "$iso.sha256"
xorriso -indev "$iso" -report_el_torito plain
xorriso -indev "$iso" -find /live -maxdepth 2 -type f -exec lsdl
