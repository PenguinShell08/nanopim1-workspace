#!/bin/bash
IFS= read -r TOKEN || true
[ -z "$TOKEN" ] && { echo "FATAL: no token"; exit 1; }
echo "=== test GH_TOKEN against api (no auth login) ==="
GH_TOKEN="$TOKEN" gh api user -q '"login=\(.login) id=\(.id)"' 2>&1
echo "exit_api_user=$?"
echo "=== emails ==="
GH_TOKEN="$TOKEN" gh api user/emails -q '.[] | "  \(.email) primary=\(.primary) verified=\(.verified) visibility=\(.visibility)"' 2>&1
echo "=== can we reach repo creation scope? (dry: list repos) ==="
GH_TOKEN="$TOKEN" gh api "user/repos?per_page=1" -q '.[].full_name' 2>&1 | head -3
echo "=== END_TEST ==="
