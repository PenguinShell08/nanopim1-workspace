#!/bin/bash
set -e
REPO_NAME="nanopim1-forensic"
VISIBILITY="private"   # safe default; user can flip to public later
cd "$HOME/nanopim1-forensic"

echo "=== 1. read token from stdin, gh login ==="
IFS= read -r TOKEN || true
[ -z "$TOKEN" ] && { echo "FATAL: no token on stdin"; exit 1; }
printf '%s' "$TOKEN" | gh auth login --with-token
echo "login ok:"; gh auth status 2>&1 | head -4

echo "=== 2. read GitHub user identity ==="
LOGIN=$(gh api user -q .login)
UID=$(gh api user -q .id)
echo "login=$LOGIN  id=$UID"

echo "=== 3. inspect emails (detect private-email protection) ==="
gh api user/emails -q '.[] | "  \(.email)  primary=\(.primary) verified=\(.verified) visibility=\(.visibility)"' 2>&1
PRIMARY_EMAIL=$(gh api user/emails -q '.[] | select(.primary==true) | .email' 2>/dev/null | head -1)
PUB_COUNT=$(gh api user/emails -q '[.[] | select(.visibility=="public")] | length' 2>/dev/null)
NOREPLY="${UID}+${LOGIN}@users.noreply.github.com"
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

echo "=== 5. rewrite commit: author + committer both corrected ==="
GIT_AUTHOR_NAME="$COMMIT_NAME" GIT_AUTHOR_EMAIL="$COMMIT_EMAIL" \
GIT_COMMITTER_NAME="$COMMIT_NAME" GIT_COMMITTER_EMAIL="$COMMIT_EMAIL" \
  git commit --amend --no-edit --reset-author >/dev/null 2>&1
echo "verify:"
git --no-pager log -1 --format='  author=%an <%ae>%n  committer=%cn <%ce>%n  hash=%H%n  subject=%s'

echo "=== 6. ensure branch name is main ==="
BR=$(git rev-parse --abbrev-ref HEAD); echo "branch=$BR"
[ "$BR" != "main" ] && git branch -M main && echo "renamed -> main"

echo "=== 7. create GitHub repo & push ==="
gh repo create "${LOGIN}/${REPO_NAME}" --${VISIBILITY} --source=. --remote=origin --push 2>&1
echo "repo meta:"
gh repo view "${LOGIN}/${REPO_NAME}" --json url,visibility,defaultBranchRef -q '  url=\(.url)  visibility=\(.visibility)  branch=\(.defaultBranchRef.name)'
echo "remote:"; git remote -v | head -2

echo "=== 8. cleanup: logout gh (token removed from VM) ==="
gh auth logout --hostname github.com 2>&1 | head -2 || true
git config --local --unset credential.helper 2>/dev/null || true
echo "final auth status:"; gh auth status 2>&1 | head -2 || true
echo "=== ALL DONE ==="
