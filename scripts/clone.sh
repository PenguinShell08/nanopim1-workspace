#!/bin/bash
set -e
cd "$HOME"
if [ -d armbian-build ]; then echo "armbian-build already exists, pulling latest"; cd armbian-build; git fetch --depth 1 origin main 2>&1 | tail -3; git reset --hard origin/main 2>&1 | tail -2; cd ..; else
  echo "cloning armbian/build (depth 1) ..."
  git clone --depth 1 https://github.com/armbian/build.git armbian-build 2>&1 | tail -5
fi
echo "=== evidence ==="
cd armbian-build
echo "branch=$(git rev-parse --abbrev-ref HEAD)"
echo "commit=$(git rev-parse --short HEAD)"
echo "compile.sh exists=$([ -f compile.sh ] && echo yes || echo no), size=$(stat -c%s compile.sh 2>/dev/null)"
echo "userpatches dir=$([ -d userpatches ] && echo yes || echo no)"
ls -1 lib/functions/ 2>/dev/null | head
echo "=== customize-image invocation (variable name) ==="
grep -rn "customize-image" lib/ 2>/dev/null | head -20
echo "=== how rootfs path is referenced near customize call ==="
grep -rn "SD_ROOT\|SDROOT\|\$DEST\|SDCARD\|customize-image" lib/functions/general.sh lib/functions/main.sh 2>/dev/null | head -30
echo "=== u-boot fetch source url ==="
grep -rn "denx\|u-boot.*git\|uboot.*url\|github.com/u-boot\|git fetch.*u-boot\|UBOOT_SOURCE\|MAINLINE_UBOOT\|u-boot.*http" lib/functions/compilation/ 2>/dev/null | head -20
echo "=== DONE_CLONE ==="
