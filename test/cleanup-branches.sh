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
set -e
