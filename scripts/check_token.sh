#!/bin/bash
IFS= read -r TOKEN || true
TOKEN=$(printf '%s' "$TOKEN" | tr -d '\r\n' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
[ -z "$TOKEN" ] && { echo "RESULT: EMPTY_TOKEN"; exit 2; }
export GH_TOKEN="$TOKEN"
OUT=$(gh api user -q .login 2>&1); RC=$?
if [ $RC -eq 0 ]; then
  echo "RESULT: VALID  login=$OUT"
else
  echo "RESULT: INVALID  rc=$RC  msg=$(echo "$OUT" | head -1)"
fi
unset GH_TOKEN
