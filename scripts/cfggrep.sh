#!/bin/bash
cd "$HOME/armbian-build"
echo "===== where is config-default.conf sourced? ====="
grep -rn "config-default.conf\|config-default\b" lib/ compile.sh 2>/dev/null | head -20
echo "===== USERPATCHES_PATH default ====="
grep -rn "USERPATCHES_PATH=" lib/functions/configuration/*.sh 2>/dev/null | head
echo "===== interactive_config_ask_kernel_configure: what var skips it? ====="
grep -n "KERNEL_CONFIGURE\|interactive_config_ask_kernel\|config_possibly_interactive" lib/functions/configuration/interactive.sh lib/functions/main/config-interactive.sh 2>/dev/null | head -20
echo "===== DONE_CFG ====="
