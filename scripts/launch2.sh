#!/bin/bash
cd /home/pc/armbian-build
./compile.sh build \
  BOARD=nanopim1 BRANCH=current RELEASE=trixie \
  BUILD_MINIMAL=yes KERNEL_CONFIGURE=no KERNEL_BTF=no EXTRAWIFI=yes BUILD_DESKTOP=no CREATE_PATCHES=no \
  KERNEL_GIT=shallow \
  PREFER_DOCKER=no REGIONAL_MIRROR=china GHPROXY_ADDRESS=gh-proxy.com \
  > /home/pc/armbian-build/build.log 2>&1
echo BUILD_EXIT=$? >> /home/pc/armbian-build/build.log
