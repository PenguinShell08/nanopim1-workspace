#!/bin/bash
cd "$HOME/armbian-build"
# clean any stale session
tmux kill-session -t armbuild 2>/dev/null || true
# launch build in a detached tmux session, log to file
tmux new-session -d -s armbuild "cd $HOME/armbian-build && ./compile.sh build > $HOME/armbian-build/build.log 2>&1; echo BUILD_EXIT=\$? >> $HOME/armbian-build/build.log"
sleep 3
echo "=== tmux sessions ==="
tmux ls 2>/dev/null
echo "=== build.log (first 30 lines) ==="
sleep 2
head -30 "$HOME/armbian-build/build.log" 2>/dev/null
echo "=== end preview ==="
