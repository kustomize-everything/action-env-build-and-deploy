#!/bin/bash

# Fail on non-zero exit
set -e

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

if [[ -n "${PUSH_ENVIRONMENT_REGEX}" ]]; then
  DEPLOY_METHOD="push"
  PUSH_BRANCH="env/${ENV}"
elif [[ -n "${PR_ENVIRONMENT_REGEX}" ]]; then
  DEPLOY_METHOD="pull-request"
  PUSH_BRANCH="deploy-pr/env/${ENV}"
else
  echo "Environment ${ENV} did not match any of the provided push or PR regexes."
  exit 1
fi

echo "DEPLOY_METHOD=${DEPLOY_METHOD}" >> "${GITHUB_ENV}"
echo "PUSH_BRANCH=${PUSH_BRANCH}" >> "${GITHUB_ENV}"

RUN_URL="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
echo "RUN_URL=${RUN_URL}" >> "${GITHUB_ENV}"
