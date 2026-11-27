#!/bin/bash
echo "=== git clone processes ==="
pgrep -af "git" | head -10
echo "=== armbian-build size & state ==="
du -sh "$HOME/armbian-build" 2>/dev/null
ls -la "$HOME/armbian-build" 2>/dev/null | head
if [ -d "$HOME/armbian-build/.git" ]; then
  cd "$HOME/armbian-build"
  echo "git_dir=present"
  echo "HEAD=$(git rev-parse --short HEAD 2>&1)"
  echo "branch=$(git branch 2>&1)"
  echo "config remote:"; git remote -v 2>&1
fi
echo "=== is clone still receiving? (count objects in 2s) ==="
s1=$(du -sb "$HOME/armbian-build/.git" 2>/dev/null | cut -f1); sleep 2; s2=$(du -sb "$HOME/armbian-build/.git" 2>/dev/null | cut -f1)
echo "size1=$s1 size2=$s2 delta=$((s2-s1))"
