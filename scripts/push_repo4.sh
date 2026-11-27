#!/bin/bash
set -e
REPO_NAME="nanopim1-forensic"
LOGIN="PenguinShell08"
EMAIL_REAL="longyanjiang87@gmail.com"
cd "$HOME/nanopim1-forensic"

echo "=== 1. read & sanitize token ==="
IFS= read -r TOKEN || true
TOKEN=$(printf '%s' "$TOKEN" | tr -d '\r\n' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
[ -z "$TOKEN" ] && { echo "FATAL: empty token"; exit 1; }
echo "token length: ${#TOKEN}"
export GH_TOKEN="$TOKEN"
EMAIL_NOREPLY="359714245+${LOGIN}@users.noreply.github.com"

echo "=== 2. ensure commit identity (real email, author+committer) ==="
git config user.name "$LOGIN"
git config user.email "$EMAIL_REAL"
git config core.quotepath false
BR=$(git rev-parse --abbrev-ref HEAD); [ "$BR" != "main" ] && git branch -M main
# only amend if identity not already correct
CUR=$(git --no-pager log -1 --format='%ae')
if [ "$CUR" != "$EMAIL_REAL" ]; then
  GIT_AUTHOR_NAME="$LOGIN" GIT_AUTHOR_EMAIL="$EMAIL_REAL" \
  GIT_COMMITTER_NAME="$LOGIN" GIT_COMMITTER_EMAIL="$EMAIL_REAL" \
    git commit --amend --no-edit --reset-author >/dev/null 2>&1
fi
git --no-pager log -1 --format='  author=%an <%ae>  committer=%cn <%ce>  hash=%H'

echo "=== 3. confirm repo exists on GitHub ==="
gh repo view "${LOGIN}/${REPO_NAME}" --json url,visibility 2>&1 | head -3

echo "=== 4. set remote via gh-proxy with embedded token & push ==="
git remote remove origin 2>/dev/null || true
PROXY_URL="https://gh-proxy.com/https://x-access-token:${TOKEN}@github.com/${LOGIN}/${REPO_NAME}.git"
git remote add origin "$PROXY_URL"
set +e
PUSH_OUT=$(git push -u origin main 2>&1); PUSH_RC=$?
set -e
echo "$PUSH_OUT"
echo "push_rc=$PUSH_RC"

# GH007 / private-email rejection -> switch to noreply and retry
USED="$EMAIL_REAL"
if echo "$PUSH_OUT" | grep -qiE 'GH007|private|protected email'; then
  echo ">>> GH007 detected -> amend to noreply and retry"
  git config user.email "$EMAIL_NOREPLY"
  GIT_AUTHOR_NAME="$LOGIN" GIT_AUTHOR_EMAIL="$EMAIL_NOREPLY" \
  GIT_COMMITTER_NAME="$LOGIN" GIT_COMMITTER_EMAIL="$EMAIL_NOREPLY" \
    git commit --amend --no-edit --reset-author >/dev/null 2>&1
  set +e
  PUSH_OUT=$(git push -u origin main 2>&1); PUSH_RC=$?
  set -e
  echo "$PUSH_OUT"; echo "push_rc=$PUSH_RC"
  USED="$EMAIL_NOREPLY"
fi

if [ "$PUSH_RC" -ne 0 ]; then
  echo "FATAL: push failed (rc=$PUSH_RC). Remote stays configured for retry."
  git remote -v | head -1
  exit 1
fi
echo ">>> PUSH OK. commit email used: $USED"

echo "=== 5. sanitize remote (strip token, keep clean github URL) ==="
git remote set-url origin "https://github.com/${LOGIN}/${REPO_NAME}.git"
git remote -v | head -2
grep -q 'x-access-token' .git/config && echo "WARNING: token in .git/config" || echo "OK: no token in .git/config"

echo "=== 6. final verification ==="
gh api "repos/${LOGIN}/${REPO_NAME}" -q '"repo=\(.full_name) visibility=\(.visibility) default_branch=\(.default_branch) pushed_at=\(.pushed_at)"' 2>&1
echo ""
echo "============================================================"
echo "  REPO_URL: https://github.com/${LOGIN}/${REPO_NAME}"
echo "  COMMIT:   $(git --no-pager log -1 --format='%h %s')"
echo "  AUTHOR:   $(git --no-pager log -1 --format='%an <%ae>')"
echo "============================================================"
unset GH_TOKEN
echo "=== ALL DONE ==="
