#!/bin/bash
cd "$HOME"
rm -rf armbian-build
echo "=== cloning via github (auto-rewritten to gh-proxy.com @8MB/s) ==="
time git clone --depth 1 https://github.com/armbian/build.git armbian-build 2>&1 | tail -4
cd armbian-build || { echo "CLONE_FAILED"; exit 1; }
echo "=== evidence ==="
echo "commit=$(git rev-parse --short HEAD)"
echo "compile.sh=$( [ -f compile.sh ] && stat -c%s compile.sh || echo MISSING)"
echo "userpatches=$( [ -d userpatches ] && echo yes || echo no)"
echo "repo_size=$(du -sh . | cut -f1)"
echo "=== customize-image hook invocation + rootfs var ==="
grep -rn "customize-image" lib/ config/ 2>/dev/null | head -15
echo "=== search for the variable passed as rootfs to customize ==="
grep -rn "SD_ROOT\|SDROOT\|customize-image\|call_extension_method.*customize\|customize-image" lib/functions/ 2>/dev/null | head -25
echo "=== where is customize-image sourced? show context ==="
grep -rln "customize-image" lib/ 2>/dev/null | while read f; do echo "--- $f ---"; grep -n "customize-image\|SD_ROOT\|SDROOT" "$f" | head -8; done
echo "=== u-boot / bootloader fetch ==="
ls lib/functions/compilation/ | grep -i "uboot\|u-boot\|bootloader"
grep -rn "denx\|gitlab.denx\|source.denx\|u-boot.*\.git\|UBOOT.*URL\|fetch_from_repo\|github.com/u-boot" lib/functions/compilation/ 2>/dev/null | head -20
echo "=== DONE_FINAL_CLONE ==="
