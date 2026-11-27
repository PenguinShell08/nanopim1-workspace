#!/bin/bash
# 1) Add 8G swap for kernel link headroom (VM has only 7.2G RAM)
if ! swapon --show | grep -q /swapfile; then
  sudo fallocate -l 8G /swapfile 2>/dev/null || sudo dd if=/dev/zero of=/swapfile bs=1M count=8192 status=none
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile >/dev/null 2>&1
  sudo swapon /swapfile
fi
echo "=== memory after swap ==="
free -h
# 2) relaunch build with KERNEL_BTF=no
cd "$HOME/armbian-build"
tmux kill-session -t armbuild 2>/dev/null || true
tmux new-session -d -s armbuild "cd $HOME/armbian-build && ./compile.sh build \
  BOARD=nanopim1 BRANCH=current RELEASE=trixie \
  BUILD_MINIMAL=yes KERNEL_CONFIGURE=no KERNEL_BTF=no EXTRAWIFI=yes BUILD_DESKTOP=no CREATE_PATCHES=no \
  PREFER_DOCKER=no REGIONAL_MIRROR=china GHPROXY_ADDRESS=gh-proxy.com \
  > $HOME/armbian-build/build.log 2>&1; echo BUILD_EXIT=\$? >> $HOME/armbian-build/build.log"
sleep 6
echo "=== tmux ==="; tmux ls 2>/dev/null
echo "=== log tail ==="; tail -5 "$HOME/armbian-build/build.log"
echo "=== END_RB3 ==="
