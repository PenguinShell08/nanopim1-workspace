#!/bin/bash
echo "=== killing tmux armbuild session ==="
tmux kill-session -t armbuild 2>&1
sleep 2
echo "=== remaining compile.sh / timeout processes ==="
pgrep -af "compile.sh|read -n1|timeout --foreground" 2>/dev/null
echo "=== force-kill any leftovers ==="
sudo pkill -9 -f "read -n1" 2>/dev/null
sudo pkill -9 -f "timeout --foreground 1 bash" 2>/dev/null
sleep 1
echo "=== after kill ==="
pgrep -af "compile.sh|armbian-build" 2>/dev/null | grep -v pgrep || echo "(none)"
echo "=== tmux sessions ==="
tmux ls 2>&1 || echo "(no sessions)"
echo "=== END_KILL ==="
