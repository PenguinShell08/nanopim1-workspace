#!/bin/bash
set -e
REPO_NAME="nanopim1-forensic"
VISIBILITY="private"
cd "$HOME/nanopim1-forensic"

echo "=== 1. read & sanitize token from stdin ==="
IFS= read -r TOKEN || true
TOKEN=$(printf '%s' "$TOKEN" | tr -d '\r\n' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
[ -z "$TOKEN" ] && { echo "FATAL: empty token"; exit 1; }
echo "token length: ${#TOKEN}"
export GH_TOKEN="$TOKEN"

echo "=== 2. read GitHub identity ==="
LOGIN=$(gh api user -q .login)
USER_ID=$(gh api user -q .id)
echo "login=$LOGIN  id=$USER_ID"

echo "=== 3. inspect emails, decide commit email ==="
gh api user/emails -q '.[] | "  \(.email) primary=\(.primary) visibility=\(.visibility)"' 2>&1
PUB_COUNT=$(gh api user/emails -q '[.[] | select(.visibility=="public")] | length')
PRIMARY_EMAIL=$(gh api user/emails -q '.[] | select(.primary==true) | .email' 2>/dev/null | head -1)
NOREPLY="${USER_ID}+${LOGIN}@users.noreply.github.com"
echo "primary=$PRIMARY_EMAIL  public_count=$PUB_COUNT  noreply=$NOREPLY"
if [ "$PUB_COUNT" = "0" ]; then
  COMMIT_EMAIL="$NOREPLY"; echo "DECISION: private protection ON -> use noreply"
else
  COMMIT_EMAIL="$PRIMARY_EMAIL"; echo "DECISION: public email present -> use primary"
fi
COMMIT_NAME="$LOGIN"

echo "=== 4. set repo-local git identity ==="
git config user.name "$COMMIT_NAME"
git config user.email "$COMMIT_EMAIL"
git config core.quotepath false
git remote remove origin 2>/dev/null || true

echo "=== 5. rewrite commit author + committer ==="
GIT_AUTHOR_NAME="$COMMIT_NAME" GIT_AUTHOR_EMAIL="$COMMIT_EMAIL" \
GIT_COMMITTER_NAME="$COMMIT_NAME" GIT_COMMITTER_EMAIL="$COMMIT_EMAIL" \
  git commit --amend --no-edit --reset-author >/dev/null 2>&1
git --no-pager log -1 --format='  author=%an <%ae>%n  committer=%cn <%ce>%n  hash=%H  subject=%s'

echo "=== 6. branch -> main ==="
BR=$(git rev-parse --abbrev-ref HEAD); [ "$BR" != "main" ] && git branch -M main
echo "branch=$(git rev-parse --abbrev-ref HEAD)"

echo "=== 7. create empty repo on GitHub ==="
gh repo create "${LOGIN}/${REPO_NAME}" --${VISIBILITY} 2>&1 || echo "(create returned non-zero, maybe already exists — continuing)"

echo "=== 8. push via token-embedded URL, then sanitize remote ==="
git remote add origin "https://x-access-token:${TOKEN}@github.com/${LOGIN}/${REPO_NAME}.git"
git push -u origin main 2>&1
git remote set-url origin "https://github.com/${LOGIN}/${REPO_NAME}.git"
echo "remote after sanitize:"; git remote -v | head -2

echo "=== 9. confirm ==="
gh repo view "${LOGIN}/${REPO_NAME}" --json url,visibility,defaultBranchRef -q '  url=\(.url)  visibility=\(.visibility)  branch=\(.defaultBranchRef.name)'
echo "  REPO_URL=https://github.com/${LOGIN}/${REPO_NAME}"

echo "=== 10. cleanup (no gh auth login was used; GH_TOKEN dies with this shell) ==="
unset GH_TOKEN
git config --local --unset credential.helper 2>/dev/null || true
grep -q 'x-access-token' .git/config && echo "WARNING: token still in .git/config!" || echo "OK: no token stored in .git/config"
echo "=== ALL DONE ==="
