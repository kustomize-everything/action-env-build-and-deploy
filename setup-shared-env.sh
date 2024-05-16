#!/bin/bash

source "${GITHUB_ACTION_PATH}/util.sh"

# Fail on non-zero exit
set -e

DEPLOY_REPO_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
echo "DEPLOY_REPO_URL=${DEPLOY_REPO_URL}" >> "${GITHUB_ENV}"

ENV_DIR="${BASE_PATH}/env/${ENV}"
echo "ENV_DIR=${ENV_DIR}" >> "${GITHUB_ENV}"

ENV_BRANCH="$(echo "${ENV_DIR}" | tr "/" "-")"
echo "ENV_BRANCH=${ENV_BRANCH}" >> "${GITHUB_ENV}"

set +e
if git branch -r --contains "origin/deploy-pr/${ENV_BRANCH}"; then
  DIFF_BRANCH="deploy-pr/${ENV_BRANCH}"
else
  DIFF_BRANCH="${ENV_BRANCH}"
fi
set -e
echo "DIFF_BRANCH=${DIFF_BRANCH}" >> "${GITHUB_ENV}"

ENV_BRANCH_URL="${DEPLOY_REPO_URL}/tree/${ENV_BRANCH}"
echo "ENV_BRANCH_URL=${ENV_BRANCH_URL}" >> "${GITHUB_ENV}"

if [[ -n "${PUSH_ENVIRONMENT_REGEX}" ]]; then
  DEPLOY_METHOD="push"
  PUSH_BRANCH="${ENV_BRANCH}"
elif [[ -n "${PR_ENVIRONMENT_REGEX}" ]]; then
  DEPLOY_METHOD="pull-request"
  PUSH_BRANCH="deploy-pr/${ENV_BRANCH}"
else
  echo "Environment ${ENV} did not match any of the provided push or PR regexes."
  exit 1
fi

echo "DEPLOY_METHOD=${DEPLOY_METHOD}" >> "${GITHUB_ENV}"
echo "PUSH_BRANCH=${PUSH_BRANCH}" >> "${GITHUB_ENV}"

RUN_URL="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
echo "RUN_URL=${RUN_URL}" >> "${GITHUB_ENV}"
