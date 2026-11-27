#!/bin/bash
cd "$HOME/armbian-build"
echo "########## BOOTSOURCE assignments across repo ##########"
grep -rn "BOOTSOURCE=" config/ lib/ 2>/dev/null | head -20
echo "########## sunxi family config location ##########"
find config -iname "*sunxi*" -o -iname "*sun8i*" 2>/dev/null | head
echo "########## nanopim1.eos content ##########"
cat config/boards/nanopim1.eos 2>/dev/null
echo "########## GHPROXY logic (main-config.sh ~260-295) ##########"
sed -n '255,295p' lib/functions/configuration/main-config.sh
echo "########## which uboot path: uboot.sh dispatch ##########"
sed -n '1,60p' lib/functions/compilation/uboot.sh
echo "########## DONE_INSPECT3 ##########"
