#!/bin/bash
tmux send-keys -t armbuild ' '
echo "sent space to tmux armbuild"
sleep 10
echo "=== git-bare size now ==="
sudo du -sh /home/pc/armbian-build/cache/git-bare 2>/dev/null
a=$(sudo du -sb /home/pc/armbian-build/cache/git-bare 2>/dev/null | cut -f1)
sleep 3
b=$(sudo du -sb /home/pc/armbian-build/cache/git-bare 2>/dev/null | cut -f1)
echo "git-bare 3s delta: $((b-a)) bytes"
echo "=== network :443 conns ==="
sudo ss -tnp 2>/dev/null | grep ':443' | head -4
echo "=== build.log tail ==="
tail -4 /home/pc/armbian-build/build.log
echo "=== END_UNBLOCK ==="
