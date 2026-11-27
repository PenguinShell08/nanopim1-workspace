#!/bin/bash
# kill the slow clone
pkill -f "git clone --depth 1 https://ghfast.top" 2>/dev/null
sleep 1
rm -rf "$HOME/armbian-build" 2>/dev/null
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999
echo "=== benchmarking github proxies (download speed, 20s each) ==="
url="https://github.com/armbian/build/archive/refs/heads/main.tar.gz"
proxies=(
  "https://ghfast.top/"
  "https://mirror.ghproxy.com/"
  "https://gh-proxy.com/"
  "https://ghproxy.net/"
  "https://gh.api.99988866.xyz/"
  "https://ghps.cc/"
)
best=""
bestspd=0
for px in "${proxies[@]}"; do
  out=$(curl -sL -o /dev/null -w '%{speed_download} %{http_code} %{size_download}' --max-time 20 "${px}${url}" 2>/dev/null)
  spd=$(echo "$out" | awk '{print $1}')
  code=$(echo "$out" | awk '{print $2}')
  spd_int=${spd%.*}
  echo "$px -> speed=${spd} B/s http=$code (spd_int=$spd_int)"
  if [ "$code" = "200" ] && [ -n "$spd_int" ] && [ "$spd_int" -gt "$bestspd" ]; then bestspd=$spd_int; best=$px; fi
done
echo "BEST_PROXY=$best  speed=${bestspd} B/s"
if [ -z "$best" ]; then echo "NO_WORKING_PROXY"; exit 2; fi
# set global insteadOf to best proxy for all git clones
git config --global --unset-all url."https://ghfast.top/https://github.com/".insteadof 2>/dev/null
git config --global --unset-all url."https://ghfast.top/https://gitlab.com/".insteadof 2>/dev/null
git config --global url."${best}https://github.com/".insteadOf "https://github.com/"
git config --global url."${best}https://gitlab.com/".insteadOf "https://gitlab.com/"
git config --global --get-regexp "url\..*\.insteadof"
echo "BEST_PROXY_SAVED=$best"
