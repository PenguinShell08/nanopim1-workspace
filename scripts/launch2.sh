#!/bin/bash
# NanoPi M1 image build. Before running, sync userpatches into the build tree:
#   scripts/customize-image.sh       -> armbian-build/userpatches/customize-image.sh
#   scripts/extensions/*.sh          -> armbian-build/userpatches/extensions/
# ENABLE_EXTENSIONS activates the filename build-stamp extension (user_config hook).
cd /home/pc/armbian-build
./compile.sh build \
  BOARD=nanopim1 BRANCH=current RELEASE=trixie \
  BUILD_MINIMAL=yes KERNEL_CONFIGURE=no KERNEL_BTF=no EXTRAWIFI=yes BUILD_DESKTOP=no CREATE_PATCHES=no \
  KERNEL_GIT=shallow \
  PREFER_DOCKER=no REGIONAL_MIRROR=china GHPROXY_ADDRESS=gh-proxy.com \
  ENABLE_EXTENSIONS=nanopim1-build-stamp BUILDER_GITHUB=PenguinShell08 \
  > /home/pc/armbian-build/build.log 2>&1
echo BUILD_EXIT=$? >> /home/pc/armbian-build/build.log
