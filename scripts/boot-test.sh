#!/bin/sh
set -eu

PROJECT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$PROJECT_DIR"

iso='dist/MoonOS-0.1-amd64.iso'
[ -f "$iso" ] || { echo "Missing $iso" >&2; exit 1; }

for command_name in qemu-system-x86_64 socat pnmtopng; do
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "Missing boot-test tool: $command_name" >&2
    exit 1
  }
done

test_dir="$(mktemp -d)"
monitor_socket="$test_dir/qemu-monitor.sock"
qemu_pid=''

cleanup() {
  if [ -n "$qemu_pid" ] && kill -0 "$qemu_pid" 2>/dev/null; then
    kill "$qemu_pid" 2>/dev/null || true
    wait "$qemu_pid" 2>/dev/null || true
  fi
  rm -rf "$test_dir"
}
trap cleanup EXIT INT TERM

qemu-system-x86_64 \
  -name 'MoonOS Boot Test' \
  -machine q35,accel=tcg \
  -cpu max -smp 2 -m 3072 \
  -boot d -cdrom "$iso" \
  -device virtio-vga \
  -display none \
  -monitor "unix:$monitor_socket,server=on,wait=off" \
  -serial file:dist/moonos-boot-serial.log \
  -no-reboot >dist/moonos-qemu.log 2>&1 &
qemu_pid="$!"

socket_wait=0
while [ ! -S "$monitor_socket" ] && [ "$socket_wait" -lt 20 ]; do
  sleep 1
  socket_wait=$((socket_wait + 1))
done
[ -S "$monitor_socket" ] || { echo 'QEMU monitor did not start.' >&2; exit 1; }

# The generated live-media menu waits for confirmation. Select the default
# MoonOS live entry just as a user pressing Enter would.
sleep 15
printf 'sendkey ret\n' | socat - "UNIX-CONNECT:$monitor_socket" >/dev/null
echo 'Selected the default MoonOS live boot entry.'

elapsed=15
for capture_at in 45 105 180 240 300 360; do
  wait_for=$((capture_at - elapsed))
  sleep "$wait_for"
  elapsed="$capture_at"

  if ! kill -0 "$qemu_pid" 2>/dev/null; then
    echo 'MoonOS virtual machine stopped before the screenshot could be captured.' >&2
    exit 1
  fi

  # Keep the virtual display awake while the live desktop is settling.  A
  # harmless Shift key also dismisses a blanked screen without opening apps.
  printf 'sendkey shift\n' | socat - "UNIX-CONNECT:$monitor_socket" >/dev/null
  sleep 2

  ppm="$test_dir/moonos-boot-${capture_at}s.ppm"
  png="dist/moonos-boot-${capture_at}s.png"
  printf 'screendump %s\n' "$ppm" | socat - "UNIX-CONNECT:$monitor_socket" >/dev/null
  pnmtopng "$ppm" > "$png"
  test -s "$png"
  echo "Captured $png"
done

echo 'MoonOS remained running for 360 seconds under QEMU.'
