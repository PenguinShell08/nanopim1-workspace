#!/bin/bash
cd "$HOME/armbian-build"
echo "########## customize-image.sh.template ##########"
sed -n '1,80p' config/templates/customize-image.sh.template
echo "########## GITHUB_SOURCE default ##########"
grep -rn "GITHUB_SOURCE=" lib/ config/ 2>/dev/null | head
echo "########## BOOTSOURCE for sunxi/sun8i (NanoPi M1) ##########"
grep -rn "BOOTSOURCE\|BOOTBRANCH" config/sources/*.conf 2>/dev/null | grep -i "sunxi\|sun8i\|allwinner" | head
echo "--- find sunxi family source file ---"
ls config/sources/ | grep -i "sun"
echo "########## nanopim1 board def ##########"
grep -rn "nanopim1\|NanoPi M1\|LINUXFAMILY=sunxi\|BOARDFAMILY=sun8i" config/boards/ 2>/dev/null | head
echo "########## fetch_from_repo: does it honor git global config? show how it clones ##########"
grep -n "git clone\|git fetch\|insteadOf\|GITHUB_SOURCE\|github" lib/functions/general.sh 2>/dev/null | head
grep -rln "fetch_from_repo" lib/functions/ | head -3
echo "########## DONE_INSPECT2 ##########"
