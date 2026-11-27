#!/bin/bash
LOG="$HOME/armbian-build/build.log"
echo "=== build.log size: $(du -h "$LOG" 2>/dev/null | cut -f1)  lines: $(wc -l < "$LOG" 2>/dev/null) ==="
echo "=== tmux alive? ==="
tmux ls 2>/dev/null || echo "NO TMUX SESSION (build may have ended)"
echo "=== compile.sh process? ==="
pgrep -af "compile.sh|make|gcc|debootstrap" | head -5 || echo "(none)"
echo "=== last 35 lines ==="
tail -35 "$LOG" 2>/dev/null
echo "=== error/exit markers ==="
grep -nE "BUILD_EXIT=|exit_with_error|Error|ERROR|failed|FAILED|No space|fatal" "$LOG" 2>/dev/null | tail -15
echo "=== phase hints ==="
grep -oiE "prepare_host|toolchain|kernel|u-boot|rootfs|customize|image|debootstrap" "$LOG" 2>/dev/null | sort | uniq -c | tail
echo "=== END_MON ==="
