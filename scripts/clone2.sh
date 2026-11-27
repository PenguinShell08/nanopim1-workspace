#!/bin/bash
cd "$HOME"
proxies=(
  "https://ghfast.top/https://github.com/armbian/build.git"
  "https://mirror.ghproxy.com/https://github.com/armbian/build.git"
  "https://gh-proxy.com/https://github.com/armbian/build.git"
  "https://ghproxy.net/https://github.com/armbian/build.git"
  "https://gh.api.99988866.xyz/https://github.com/armbian/build.git"
)
chosen=""
for p in "${proxies[@]}"; do
  echo "--- probing $p ---"
  if timeout 25 git ls-remote "$p" HEAD >/dev/null 2>&1; then
    echo "OK: $p"; chosen="$p"; break
  else
    echo "fail: $p"
  fi
done
if [ -z "$chosen" ]; then echo "NO_PROXY_WORKED"; exit 2; fi
echo "=== cloning via $chosen ==="
rm -rf armbian-build
git clone --depth 1 "$chosen" armbian-build 2>&1 | tail -5
echo "=== evidence ==="
cd armbian-build || { echo "clone did not produce dir"; exit 1; }
echo "commit=$(git rev-parse --short HEAD)"
echo "compile.sh size=$(stat -c%s compile.sh 2>/dev/null)"
echo "userpatches=$([ -d userpatches ] && echo yes || echo no)"
echo "=== customize-image refs ==="
grep -rn "customize-image" lib/ 2>/dev/null | head -15
echo "=== rootfs var near customize ==="
grep -rn "SD_ROOT\|SDROOT\|customize-image\|\$SDCARD" lib/functions/*.sh lib/functions/**/*.sh 2>/dev/null | grep -i "custom\|SD_ROOT\|SDROOT" | head -20
echo "=== u-boot source fetch ==="
grep -rn "denx\|u-boot.*\.git\|UBOOT\|github.com/u-boot" lib/functions/compilation/uboot*.sh lib/functions/compilation/u-boot*.sh 2>/dev/null | head -20
echo "=== DONE_CLONE2 ==="
