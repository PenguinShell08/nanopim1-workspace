#!/bin/bash
echo "=== pip / python processes ==="
pgrep -af "pip|python|requirements" | head
echo "=== is build.log growing? (size now vs in 3s) ==="
s1=$(stat -c%s "$HOME/armbian-build/build.log"); sleep 3; s2=$(stat -c%s "$HOME/armbian-build/build.log")
echo "log: $s1 -> $s2 (delta $((s2-s1)))"
echo "=== cache dir size ==="
du -sh "$HOME/armbian-build/cache" 2>/dev/null
du -sh "$HOME/armbian-build/cache"/* 2>/dev/null | head
echo "=== active network connections (pypi/ghcr/gitee/tuna) ==="
ss -tnp 2>/dev/null | grep -iE ":443|:80" | head -15
echo "=== any pip download dirs growing? ==="
find /root /tmp -maxdepth 3 -iname "*pip*" 2>/dev/null | head
ls -la /root/.cache/pip 2>/dev/null | head
echo "=== last 6 lines build.log ==="
tail -6 "$HOME/armbian-build/build.log"
echo "=== END_DIAG ==="
