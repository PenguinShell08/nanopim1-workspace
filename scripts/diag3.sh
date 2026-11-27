#!/bin/bash
echo "=== compile.sh process tree ==="
pid=$(pgrep -f "compile.sh.*build" | tail -1)
echo "compile pid=$pid"
ps -ef --forest 2>/dev/null | grep -A 20 " $pid " | grep -v grep | head -30
echo "=== all children wchan ==="
for c in $(pgrep -P $pid); do
  comm=$(sudo cat /proc/$c/comm 2>/dev/null); wc=$(sudo cat /proc/$c/wchan 2>/dev/null)
  echo "child $c ($comm) wchan=$wc"
  for gc in $(pgrep -P $c); do
    gcomm=$(sudo cat /proc/$gc/comm 2>/dev/null); gwc=$(sudo cat /proc/$gc/wchan 2>/dev/null)
    echo "  grandchild $gc ($gcomm) wchan=$gwc"
  done
done
echo "=== latest .tmp log dirs ==="
ls -dt /home/pc/armbian-build/.tmp/logs-* 2>/dev/null | head -3
latest=$(ls -dt /home/pc/armbian-build/.tmp/logs-* 2>/dev/null | head -1)
echo "latest=$latest"
echo "=== files in latest log dir (by mtime) ==="
sudo ls -lt "$latest" 2>/dev/null | head -10
echo "=== tail of the most recently modified log file ==="
newest=$(sudo ls -t "$latest"/* 2>/dev/null | head -1)
echo "newest=$newest"
sudo tail -25 "$newest" 2>/dev/null
echo "=== END_DIAG3 ==="
