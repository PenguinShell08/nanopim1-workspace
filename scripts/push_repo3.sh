#!/bin/bash
set -e
REPO_NAME="nanopim1-forensic"
VISIBILITY="private"
cd "$HOME/nanopim1-forensic"

echo "=== 1. read & sanitize token ==="
IFS= read -r TOKEN || true
TOKEN=$(printf '%s' "$TOKEN" | tr -d '\r\n' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
[ -z "$TOKEN" ] && { echo "FATAL: empty token"; exit 1; }
echo "token length: ${#TOKEN}"
export GH_TOKEN="$TOKEN"

echo "=== 2. read GitHub identity ==="
LOGIN=$(gh api user -q .login)
USER_ID=$(gh api user -q .id)
echo "login=$LOGIN  id=$USER_ID"
EMAIL_REAL="longyanjiang87@gmail.com"
EMAIL_NOREPLY="${USER_ID}+${LOGIN}@users.noreply.github.com"
echo "candidate emails: real=$EMAIL_REAL  noreply=$EMAIL_NOREPLY"

echo "=== 3. set identity to real email, amend commit (author+committer) ==="
git config user.name "$LOGIN"
git config user.email "$EMAIL_REAL"
git config core.quotepath false
git remote remove origin 2>/dev/null || true
GIT_AUTHOR_NAME="$LOGIN" GIT_AUTHOR_EMAIL="$EMAIL_REAL" \
GIT_COMMITTER_NAME="$LOGIN" GIT_COMMITTER_EMAIL="$EMAIL_REAL" \
  git commit --amend --no-edit --reset-author >/dev/null 2>&1
BR=$(git rev-parse --abbrev-ref HEAD); [ "$BR" != "main" ] && git branch -M main
git --no-pager log -1 --format='  author=%an <%ae>  committer=%cn <%ce>'

echo "=== 4. create empty repo on GitHub ($VISIBILITY) ==="
gh repo create "${LOGIN}/${REPO_NAME}" --${VISIBILITY} 2>&1 || echo "(create returned non-zero — may already exist; continuing)"

echo "=== 5. add token-embedded remote & push (attempt 1: real email) ==="
git remote add origin "https://x-access-token:${TOKEN}@github.com/${LOGIN}/${REPO_NAME}.git"
PUSH_OUT=$(git push -u origin main 2>&1) || true
echo "$PUSH_OUT"

USED_EMAIL="$EMAIL_REAL"
if echo "$PUSH_OUT" | grep -qiE 'GH007|private|protected email'; then
  echo ">>> GH007/private-email rejection detected -> switching to noreply"
  git config user.email "$EMAIL_NOREPLY"
  GIT_AUTHOR_NAME="$LOGIN" GIT_AUTHOR_EMAIL="$EMAIL_NOREPLY" \
  GIT_COMMITTER_NAME="$LOGIN" GIT_COMMITTER_EMAIL="$EMAIL_NOREPLY" \
    git commit --amend --no-edit --reset-author >/dev/null 2>&1
  PUSH_OUT=$(git push -u origin main 2>&1) || true
  echo "$PUSH_OUT"
  USED_EMAIL="$EMAIL_NOREPLY"
fi

# final success check
if echo "$PUSH_OUT" | grep -qiE 'error|failed|rejected|denied'; then
  echo "FATAL: push did not succeed"; exit 1
fi
echo ">>> push succeeded, commit email used: $USED_EMAIL"

echo "=== 6. sanitize remote URL (remove token) ==="
git remote set-url origin "https://github.com/${LOGIN}/${REPO_NAME}.git"
git remote -v | head -2

echo "=== 7. confirm repo ==="
gh repo view "${LOGIN}/${REPO_NAME}" --json url,visibility,defaultBranchRef -q '  url=\(.url) visibility=\(.visibility) branch=\(.defaultBranchRef.name)'
git --no-pager log -1 --format='  final: author=%an <%ae>  committer=%cn <%ce>  hash=%H'
echo ""
echo "REPO_URL=https://github.com/${LOGIN}/${REPO_NAME}"

echo "=== 8. cleanup ==="
unset GH_TOKEN
git config --local --unset credential.helper 2>/dev/null || true
grep -q 'x-access-token' .git/config && echo "WARNING: token leaked in .git/config" || echo "OK: no token in .git/config"
echo "=== ALL DONE ==="
