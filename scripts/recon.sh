#!/bin/bash
echo "===== OS ====="
. /etc/os-release; echo "$PRETTY_NAME  ($VERSION_ID)"
uname -r; echo "arch=$(dpkg --print-architecture)"
echo
echo "===== HOME top-level ====="
ls -la "$HOME"
echo
echo "===== search build artifacts (whole fs, shallow) ====="
find /home /root /opt /armbian /build -maxdepth 4 \( -iname '*armbian*' -o -name 'customize-final.sh' -o -iname '*nanopi*' -o -name 'compile.sh' \) 2>/dev/null
echo
echo "===== /root ====="; ls -la /root 2>/dev/null || echo "(no access /root)"
echo "===== /opt ====="; ls -la /opt 2>/dev/null
echo "===== /armbian /build ====="; ls -la /armbian 2>/dev/null; ls -la /build 2>/dev/null
echo
echo "===== tools present? ====="
for t in git gcc g++ make docker debootstrap cpio mkimage qemu-user-static qemu-arm-static rsync aria2c jq xz bc dialog; do
  if command -v "$t" >/dev/null 2>&1; then echo "OK   $t"; else echo "MISS $t"; fi
done
echo
echo "===== apt sources ====="; head -3 /etc/apt/sources.list 2>/dev/null; ls /etc/apt/sources.list.d/ 2>/dev/null
echo
echo "===== resources ====="; nproc; free -h | head -2; df -h / | tail -1
echo
echo "===== internet (github + tuna) ====="
timeout 10 curl -sI https://github.com 2>&1 | head -1
timeout 10 curl -sI https://mirrors.tuna.tsinghua.edu.cn 2>&1 | head -1
echo
echo "===== lxd / lxc ====="
command -v lxc >/dev/null 2>&1 && { echo "lxc present"; lxc list 2>&1 | head -12; } || echo "lxc MISSING"
echo
echo "===== docker ====="
command -v docker >/dev/null 2>&1 && { docker ps -a 2>&1 | head -8; } || echo "docker MISSING"
echo
echo "===== RECON_DONE ====="
