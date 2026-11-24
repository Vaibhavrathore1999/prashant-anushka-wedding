#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
repo='Vaibhavrathore1999/prashant-anushka-wedding'
gh api user --jq .login
if ! gh repo view "$repo" >/dev/null 2>&1; then
  gh repo create "$repo" --public --description 'Wedding invitation for Prashant Patel and Anushka Rathore'
fi
if git remote get-url github >/dev/null 2>&1; then
  remote_url="$(git remote get-url github)"
  if [[ "$remote_url" != "https://github.com/$repo.git" ]]; then
    printf 'The github remote points to another repository: %s\n' "$remote_url"
    exit 1
  fi
else
  git remote add github "https://github.com/$repo.git"
fi
git push -u github main
git subtree push --prefix dist github gh-pages
if gh api "repos/$repo/pages" >/dev/null 2>&1; then
  gh api --method PUT "repos/$repo/pages" -f build_type=legacy -f 'source[branch]=gh-pages' -f 'source[path]=/' >/dev/null
else
  gh api --method POST "repos/$repo/pages" -f build_type=legacy -f 'source[branch]=gh-pages' -f 'source[path]=/' >/dev/null
fi
printf '\nGitHub Pages deployment started.\n'
printf 'Invitation URL after deployment: https://vaibhavrathore1999.github.io/prashant-anushka-wedding/\n'
printf 'Deployment progress: https://github.com/%s/actions\n' "$repo"
