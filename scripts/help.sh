#!/bin/bash
cd "$HOME/armbian-build"
echo "===== docker installed? ====="
command -v docker && docker --version || echo "docker NOT installed"
echo "===== DOCKER default in config ====="
grep -rn "DOCKER" lib/functions/configuration/*.sh lib/functions/cli/*.sh 2>/dev/null | head -20
echo "===== cli build help (first 60 lines) ====="
timeout 60 ./compile.sh build --help 2>&1 | head -60
echo "rc=$?"
echo "===== DONE_HELP ====="
