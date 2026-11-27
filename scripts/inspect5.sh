#!/bin/bash
cd "$HOME/armbian-build"
echo "########## main-config.sh 195-335 (mirror defaults) ##########"
sed -n '195,335p' lib/functions/configuration/main-config.sh
echo "########## toolchain download source ##########"
grep -rn "toolchain\|TOOLCHAIN\|dl.armbian\|github.com.*armbian.*toolchain\|releases/download" lib/functions/compilation/ 2>/dev/null | grep -i "url\|http\|download\|source" | head -15
echo "########## DONE_INSPECT5 ##########"
