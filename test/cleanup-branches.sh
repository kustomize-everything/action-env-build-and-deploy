#!/bin/bash

REPO="$1"

cd "${REPO}" || exit 1
set -e
git push --delete origin env-dev
git push --delete origin deploy-pr/env-dev
