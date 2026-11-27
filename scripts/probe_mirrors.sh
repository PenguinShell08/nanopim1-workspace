#!/bin/bash
echo "=== probe build mirrors from VM ==="
probe(){ local name="$1" url="$2"; local code; code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 15 "$url" 2>/dev/null); echo "$name -> HTTP $code  ($url)"; }
probe "ghcr.nju.edu.cn (OCI gitball mirror)" "https://ghcr.nju.edu.cn/v2/"
probe "gitee.com (u-boot mirror)"          "https://gitee.com/"
probe "gh-proxy.com (github proxy)"       "https://gh-proxy.com/https://github.com/armbian/build"
probe "tuna kernel git"                   "https://mirrors.tuna.tsinghua.edu.cn/git/linux-stable.git"
probe "dl.armbian.com (cdn)"              "https://dl.armbian.com/"
echo
echo "=== create userpatches dir ==="
mkdir -p "$HOME/armbian-build/userpatches"
echo "userpatches exists: $([ -d "$HOME/armbian-build/userpatches" ] && echo yes)"
ls -la "$HOME/armbian-build/userpatches"
echo "=== tmux available? ==="
command -v tmux && tmux -V || echo "tmux MISSING (will use nohup)"
echo "=== DONE_PROBE ==="
