#!/bin/bash

if ! git diff --quiet "origin/${DIFF_BRANCH}" ; then
  if [ -n "${GIT_COMMIT_MESSAGE}" ]; then
    git commit -m "${GIT_COMMIT_MESSAGE}

    skip-checks: true
    "
  else
    git commit -m "${GIT_HEAD_COMMIT_MESSAGE}

    skip-checks: true
    "
  fi
  git diff "origin/${DIFF_BRANCH}" > git-diff
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
  echo "There are no changes to push to the ${DIFF_BRANCH} branch."
fi
