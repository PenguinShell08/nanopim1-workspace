#!/bin/bash
# Install + verify Armbian build dependencies. Evidence-gated.
export DEBIAN_FRONTEND=noninteractive
echo "=== apt update ==="
sudo apt-get update -y 2>&1 | tail -5
echo "=== apt install ==="
sudo apt-get install -y --no-install-recommends \
  git curl ca-certificates coreutils cpio u-boot-tools debootstrap qemu-user-static qemu-user binfmt-support \
  aria2 dialog bc xz-utils rsync jq make gcc g++ flex bison libssl-dev libelf-dev dwarves kmod \
  python3-dev python3-setuptools python3-pip swig libgnutls28-dev device-tree-compiler \
  parted fdisk dosfstools e2fsprogs f2fs-tools ntfs-3g qemu-utils \
  zip unzip zstd pigz lzop lz4 gnupg dirmngr apt-cacher-ng 2>&1 | tail -8
echo "=== verify critical binaries (evidence gate) ==="
ok=1
for b in mkimage cpio debootstrap qemu-arm-static aria2c dialog gcc make bc xz rsync jq git curl fdisk parted; do
  p="$(command -v $b 2>/dev/null)"
  if [ -n "$p" ] && [ -x "$p" ]; then echo "OK   $b -> $p"; else echo "MISS $b"; ok=0; fi
done
echo "=== arm binfmt ==="
if [ -f /proc/sys/fs/binfmt_misc/qemu-arm ]; then
  echo "OK binfmt qemu-arm registered"
else
  echo "WARN binfmt qemu-arm missing; trying update-binfmts"
  sudo update-binfmts --enable qemu-arm 2>/dev/null && echo "enabled" || echo "could not enable (may need reboot)"
fi
echo "=== qemu-arm-static can exec arm binary? ==="
qemu-arm-static --version 2>/dev/null | head -1 && echo "OK qemu-arm-static callable" || echo "WARN qemu-arm-static not callable"
echo "=== resources ==="
echo "mem: $(free -h | awk '/^Mem:/{print $2}') total, $(free -h | awk '/^Mem:/{print $7}') avail"
echo "disk: $(df -h / | awk 'NR==2{print $4}') free on /"
echo "cores: $(nproc)"
echo "DEPS_EXIT=$ok"
