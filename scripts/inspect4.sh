#!/bin/bash
cd "$HOME/armbian-build"
echo "########## uboot-git-oras.sh (first 90 lines) ##########"
sed -n '1,90p' lib/functions/compilation/uboot-git-oras.sh
echo "########## GHCR_SOURCE / GHCR_MIRROR / GIT_ORAS defaults ##########"
grep -rn "GHCR_SOURCE\|GHCR_MIRROR\|GIT_ORAS_TARBALLS\|oras" lib/functions/configuration/ lib/functions/general.sh 2>/dev/null | head -20
echo "########## sunxi_common.inc ##########"
cat config/sources/families/include/sunxi_common.inc 2>/dev/null
echo "########## sun8i.conf ##########"
cat config/sources/families/sun8i.conf 2>/dev/null
echo "########## KERNELSOURCE for sunxi (grep) ##########"
grep -rn "KERNELSOURCE\|KERNEL_MAJOR_MINOR\|KERNELBRANCH" config/sources/families/include/sunxi_common.inc config/sources/families/sun8i.conf 2>/dev/null
echo "########## DONE_INSPECT4 ##########"
