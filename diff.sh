#!/bin/bash

DIFF_BRANCH_HEAD_SHA="$(git show-ref --hash "origin/${DIFF_BRANCH}")"
echo "DIFF_BRANCH_HEAD_SHA=${DIFF_BRANCH_HEAD_SHA}" >> "${GITHUB_ENV}"
DIFF_BRANCH_HEAD_SHORT_SHA="$(git show-ref --hash=6 "origin/${DIFF_BRANCH}")"
echo "DIFF_BRANCH_HEAD_SHORT_SHA=${DIFF_BRANCH_HEAD_SHORT_SHA}" >> "${GITHUB_ENV}"
DIFF_BRANCH_HEAD_SHA_URL="$DEPLOY_REPO_URL/commit/$DIFF_BRANCH_HEAD_SHA"
echo "DIFF_BRANCH_HEAD_SHA_URL=${DIFF_BRANCH_HEAD_SHA_URL}" >> "${GITHUB_ENV}"

if ! git diff --quiet "origin/${DIFF_BRANCH}" --; then
  # Fail on non-zero exit
  set -e

  git diff "origin/${DIFF_BRANCH}" -- > git-diff
  echo "git diff origin/${DIFF_BRANCH}:"
  cat git-diff
  # shellcheck disable=SC2129
  echo "diff<<$EOF" >> "${GITHUB_OUTPUT}"
  # shellcheck disable=SC2129
  cat git-diff >> "${GITHUB_OUTPUT}"
  # shellcheck disable=SC2129
  echo "$EOF" >> "${GITHUB_OUTPUT}"
  bytes="$(wc -c < git-diff | tr -d ' \n')"
  echo
  echo "Bytes: ${bytes}"
  echo "diff-bytes=${bytes}" >> "${GITHUB_OUTPUT}"
  rm git-diff
else
  echo "There are no changes to push to the ${PUSH_BRANCH} branch when
    compared with origin/${DIFF_BRANCH}."
fi
