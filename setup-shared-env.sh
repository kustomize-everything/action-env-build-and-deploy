#!/bin/bash

DEPLOY_REPO_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
echo "DEPLOY_REPO_URL=${DEPLOY_REPO_URL}" >> "${GITHUB_ENV}"

DEPLOY_BRANCH="env/${ENV}"
echo "DEPLOY_BRANCH=${DEPLOY_BRANCH}" >> "${GITHUB_ENV}"

ENV_DIR="env/${ENV}"
echo "ENV_DIR=${ENV_DIR}" >> "${GITHUB_ENV}"

set +e
if git branch -r --contains "origin/deploy-pr/env/${ENV}"; then
  DIFF_BRANCH="deploy-pr/env/${ENV}"
else
  DIFF_BRANCH="env/${ENV}"
fi
set -e
echo "DIFF_BRANCH=${DIFF_BRANCH}" >> "${GITHUB_ENV}"

DEPLOY_BRANCH_URL="${DEPLOY_REPO_URL}/tree/${DEPLOY_BRANCH}"
echo "DEPLOY_BRANCH_URL=${DEPLOY_BRANCH_URL}" >> "${GITHUB_ENV}"

RUN_URL="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
echo "RUN_URL=${RUN_URL}" >> "${GITHUB_ENV}"
