#!/bin/bash
echo "=== build.log size ==="
wc -l /home/pc/armbian-build/build.log
echo "=== tmux alive? ==="
tmux ls 2>&1 | head -2
echo "=== BUILD_EXIT in log? ==="
grep -c "BUILD_EXIT=" /home/pc/armbian-build/build.log 2>/dev/null
echo "=== error markers ==="
grep -niE "error:|Error |fatal|OOM|killed process|No space|exited with|returning non-zero|failed" /home/pc/armbian-build/build.log | tail -8
echo "=== memory ==="
free -h
echo "=== top 4 CPU procs ==="
ps -eo pcpu,pmem,comm,args --sort=-pcpu 2>/dev/null | head -5
echo "=== last 12 log lines ==="
tail -12 /home/pc/armbian-build/build.log
echo "=== END_MON2 ==="
