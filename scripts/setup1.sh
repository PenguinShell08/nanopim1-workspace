#!/bin/bash
set -e
echo "pc ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/pc-nopasswd
chmod 440 /etc/sudoers.d/pc-nopasswd
sudo -n true && echo "NOPASSWD_SUDO_OK" || { echo "NOPASSWD_FAIL"; exit 1; }
apt-get update -qq 2>&1 | tail -3
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl git ca-certificates coreutils 2>&1 | tail -4
echo "--- tools ---"
for t in curl git timeout; do command -v "$t" >/dev/null && echo "OK $t" || echo "MISS $t"; done
echo "--- net ---"
curl -sI --max-time 12 https://github.com 2>&1 | head -1
curl -sI --max-time 12 https://mirrors.tuna.tsinghua.edu.cn 2>&1 | head -1
echo "SETUP1_DONE"
