#!/bin/bash

DIFF_BRANCH_HEAD_SHA="$(git show-ref --hash "origin/${DIFF_BRANCH}")"
echo "DIFF_BRANCH_HEAD_SHA=${DIFF_BRANCH_HEAD_SHA}" >> "${GITHUB_ENV}"

if ! git diff --quiet "origin/${DIFF_BRANCH}" --; then
  # Fail on non-zero exit
  set -e

  git diff "origin/${DIFF_BRANCH}" -- > git-diff
  echo "git diff origin/${DIFF_BRANCH}:"
  cat git-diff
  diff="$(cat git-diff)"
  diff="${diff//'%'/'%25'}"
  diff="${diff//$'\n'/'%0A'}"
  diff="${diff//$'\r'/'%0D'}"
  echo "::set-output name=diff::$diff"
  echo "Diff:"
  echo "${diff}"
  bytes="$(wc -c < git-diff | tr -d ' \n')"
  echo
  echo "Bytes: ${bytes}"
  echo "::set-output name=diff-bytes::$bytes"
  rm git-diff
else
  echo "There are no changes to push to the ${PUSH_BRANCH} branch when
    compared with origin/${DIFF_BRANCH}."
fi
