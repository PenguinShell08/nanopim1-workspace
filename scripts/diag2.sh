#!/bin/bash
echo "=== cache dir sizes (root) ==="
sudo du -sh /home/pc/armbian-build/cache/* 2>/dev/null | sort -h | tail -15
echo "=== is cache/git-bare growing? (2s delta) ==="
a=$(sudo du -sb /home/pc/armbian-build/cache/git-bare 2>/dev/null | cut -f1); sleep 2; b=$(sudo du -sb /home/pc/armbian-build/cache/git-bare 2>/dev/null | cut -f1)
echo "git-bare: $a -> $b  delta=$((b-a))"
echo "=== active network conns ==="
sudo ss -tnp 2>/dev/null | grep -E ":443" | head
echo "=== build.log raw tail (show CR) ==="
sudo tail -c 400 /home/pc/armbian-build/build.log | cat -v | tail -8
echo "=== what is compile.sh child doing? (wchan) ==="
pid=$(pgrep -f "compile.sh.*build" | tail -1)
echo "compile pid=$pid"
for c in $(pgrep -P $pid); do echo "child $c: $(sudo cat /proc/$c/comm 2>/dev/null) wchan=$(sudo cat /proc/$c/wchan 2>/dev/null)"; done
echo "=== END_DIAG2 ==="
