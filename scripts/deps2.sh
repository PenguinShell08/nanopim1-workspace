#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo "=== apt install (corrected: qemu-user-binfmt, lean list) ==="
sudo apt-get install -y --no-install-recommends \
  qemu-user-binfmt qemu-user \
  cpio u-boot-tools debootstrap \
  aria2 dialog bc xz-utils rsync jq \
  make gcc g++ flex bison libssl-dev libelf-dev dwarves kmod \
  python3-dev python3-setuptools swig libgnutls28-dev device-tree-compiler \
  parted fdisk dosfstools e2fsprogs f2fs-tools qemu-utils \
  zip unzip zstd pigz lzop lz4 gnupg dirmngr 2>&1 | tail -6
echo "=== apt install status rc=$? ==="
echo "=== verify critical binaries ==="
ok=1
for b in mkimage cpio debootstrap qemu-arm-static aria2c dialog gcc make bc xz rsync jq git curl fdisk parted flex bison; do
  p="$(command -v $b 2>/dev/null)"
  if [ -n "$p" ] && [ -x "$p" ]; then echo "OK   $b"; else echo "MISS $b"; ok=0; fi
done
echo "=== arm binfmt ==="
if [ -f /proc/sys/fs/binfmt_misc/qemu-arm ]; then echo "OK binfmt qemu-arm"; else echo "MISS binfmt qemu-arm"; fi
qemu-arm-static --version 2>/dev/null | head -1
echo "DEPS2_EXIT=$ok"
