#!/bin/bash
set -e
echo "=== get latest gh version ==="
VER=""
if command -v jq >/dev/null 2>&1; then
  VER=$(curl -fsSL --max-time 20 https://api.github.com/repos/cli/cli/releases/latest 2>/dev/null | jq -r '.tag_name' 2>/dev/null | sed 's/^v//')
fi
if [ -z "$VER" ] || [ "$VER" = "null" ]; then
  echo "api.github.com unreachable, trying gh-proxy mirror of releases page..."
  VER=$(curl -fsSL --max-time 25 "https://gh-proxy.com/https://github.com/cli/cli/releases/latest" 2>/dev/null | grep -oE '/cli/cli/releases/tag/v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
fi
echo "resolved version: ${VER:-UNKNOWN}"
[ -z "$VER" ] && { echo "FATAL: cannot resolve gh version"; exit 1; }

URL="https://github.com/cli/cli/releases/download/v${VER}/gh_${VER}_linux_amd64.tar.gz"
PROXY="https://gh-proxy.com/${URL}"
echo "=== downloading via gh-proxy ==="
cd /tmp
rm -rf gh_install && mkdir gh_install && cd gh_install
curl -fL --max-time 180 -o gh.tar.gz "$PROXY"
ls -lh gh.tar.gz
tar xzf gh.tar.gz
BIN=$(find . -name gh -type f -path '*bin*' | head -1)
echo "binary: $BIN"
sudo cp "$BIN" /usr/local/bin/gh
sudo chmod +x /usr/local/bin/gh
echo "=== install result ==="
which gh
gh --version
echo "=== END_INSTALL_GH ==="
