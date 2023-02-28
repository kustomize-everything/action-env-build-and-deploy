#!/bin/bash

REPO="$1"

cd "${REPO}" || exit 1
set +e
if git ls-remote --exit-code --heads origin env-dev; then
git push --delete origin env-dev
fi
if git ls-remote --exit-code --heads origin deploy-pr/env-dev; then
git push --delete origin deploy-pr/env-dev
fi

# Delete all origin branches prefixed with pr/
for branch in $(git ls-remote --heads origin | grep -o 'pr/.*' | cut -d '/' -f 2); do
  git push --delete origin "pr/${branch}"
done

set -e
