#!/bin/bash
if [ -d "$HOME/armbian-build/.git" ]; then
  cd "$HOME/armbian-build"
  echo "DIR_EXISTS"
  echo "commit=$(git rev-parse --short HEAD 2>/dev/null)"
  if [ -f compile.sh ]; then echo "compile_sh=$(stat -c%s compile.sh)"; else echo "compile_sh=MISSING"; fi
  echo "size=$(du -sh . 2>/dev/null | cut -f1)"
else
  echo "NOT_YET"
fi
