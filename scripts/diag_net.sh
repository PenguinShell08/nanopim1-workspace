echo "=== global git insteadOf / proxy ==="
git config --global --list 2>/dev/null | grep -iE 'insteadof|proxy|url' || echo "(none)"
echo "=== repo exists? ==="
GH_TOKEN=$(cat) # placeholder, not used here
echo "=== direct github reachability ==="
curl -sS -o /dev/null -w "direct github.com: http=%{http_code} time=%{time_total}s\n" --max-time 12 https://github.com 2>&1 || echo "direct FAILED"
echo "=== gh-proxy reachability ==="
curl -sS -o /dev/null -w "gh-proxy github: http=%{http_code} time=%{time_total}s\n" --max-time 12 "https://gh-proxy.com/https://github.com/PenguinShell08/nanopim1-forensic" 2>&1 || echo "proxy FAILED"
echo "=== END_DIAG ==="