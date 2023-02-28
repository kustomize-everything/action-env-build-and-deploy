#!/bin/bash

REPO="$1"

cd "${REPO}" || exit 1
set +e
if git ls-remote --exit-code --heads origin refs/heads/env-dev; then
    set -e
    git push --delete origin env-dev
fi
if git ls-remote --exit-code --heads origin refs/heads/deploy-pr/env-dev; then
    set -e
    git push --delete origin deploy-pr/env-dev
fi
