#!/bin/bash
set -e
REPO="$HOME/nanopim1-forensic"
SRC="$HOME/armbian-build/userpatches/customize-image.sh"

rm -rf "$REPO"
mkdir -p "$REPO"
cp "$SRC" "$REPO/customize-image.sh"
chmod 755 "$REPO/customize-image.sh"

cat > "$REPO/build.sh" <<'EOF'
#!/bin/bash
# Reproducible build: latest Armbian for NanoPi M1
# (Debian trixie, current kernel) with forensic hooks from customize-image.sh.
#
# Usage:
#   1. git clone https://github.com/armbian/build.git
#   2. copy customize-image.sh (and this build.sh) into build/userpatches/
#   3. cd build && bash userpatches/build.sh
#
# China mirrors: kernel/firmware via tuna, OCI gitballs via NJU,
# github via gh-proxy.com. KERNEL_GIT=shallow skips the interactive
# bare-tree countdown; KERNEL_BTF=no avoids the RAM check on <8GB hosts.
set -e
cd "$(dirname "$0")/.."
./compile.sh build \
  BOARD=nanopim1 BRANCH=current RELEASE=trixie \
  BUILD_MINIMAL=yes KERNEL_CONFIGURE=no KERNEL_BTF=no EXTRAWIFI=yes \
  BUILD_DESKTOP=no CREATE_PATCHES=no \
  KERNEL_GIT=shallow \
  PREFER_DOCKER=no REGIONAL_MIRROR=china GHPROXY_ADDRESS=gh-proxy.com
EOF
chmod 755 "$REPO/build.sh"

cat > "$REPO/.gitignore" <<'EOF'
# Armbian build artifacts
output/
.cache/
*.img
*.img.xz
*.img.sha
*.img.txt
*.log

# OS / editor
.DS_Store
Thumbs.db
EOF

cd "$REPO"
git init -q
git config core.quotepath false
# NOTE: repo-local identity is temporary. Set your own before pushing to GitHub:
#   git config user.name "YourName"
#   git config user.email "you@example.com"
#   git commit --amend --reset-author --no-edit
git config user.name "light"
git config user.email "light@example.local"
git add -A
git commit -q -m "NanoPi M1 Armbian forensic hooks + reproducible build

- customize-image.sh: journald persistent, machine-id normalized to 32 hex,
  journal-mirror / shutdown-snapshot / auto-diag (tty1) forensic services
- build.sh: exact compile invocation (trixie/current, china mirrors,
  KERNEL_GIT=shallow, KERNEL_BTF=no)"
echo "=== repo ready ==="
git --no-pager log --oneline
echo "=== files tracked ==="
git ls-files
echo "=== status ==="
git status --short
echo "=== identity (local) ==="
git config user.name; git config user.email
echo "=== END_MAKEREPO ==="
