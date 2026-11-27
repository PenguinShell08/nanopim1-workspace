#!/bin/bash
cd "$HOME/armbian-build"
# config-default.conf is NOT auto-sourced (a TODO in the code); pass everything on CLI.
rm -f userpatches/config-default.conf 2>/dev/null
tmux kill-session -t armbuild 2>/dev/null || true
tmux new-session -d -s armbuild "cd $HOME/armbian-build && ./compile.sh build \
  BOARD=nanopim1 BRANCH=current RELEASE=trixie \
  BUILD_MINIMAL=yes KERNEL_CONFIGURE=no EXTRAWIFI=yes BUILD_DESKTOP=no CREATE_PATCHES=no \
  PREFER_DOCKER=no REGIONAL_MIRROR=china GHPROXY_ADDRESS=gh-proxy.com \
  > $HOME/armbian-build/build.log 2>&1; echo BUILD_EXIT=\$? >> $HOME/armbian-build/build.log"
sleep 5
echo "=== tmux ==="; tmux ls 2>/dev/null
echo "=== build.log head ==="; head -25 "$HOME/armbian-build/build.log" 2>/dev/null
echo "=== END_RB2 ==="
