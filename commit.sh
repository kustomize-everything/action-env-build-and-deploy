#!/bin/bash

if [ -z "${GIT_COMMIT_MESSAGE}" ]; then
    GIT_COMMIT_MESSAGE="${GIT_HEAD_COMMIT_MESSAGE}"
fi
# Multi-line output
# Reference: https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings
EOF=$(dd if=/dev/urandom bs=15 count=1 status=none | base64)
echo "commit-message<<$EOF" >> "${GITHUB_OUTPUT}"
echo "${GIT_COMMIT_MESSAGE}" >> "${GITHUB_OUTPUT}"
echo "$EOF" >> "${GITHUB_OUTPUT}"

set +e
if ! git diff --quiet "origin/${DIFF_BRANCH}" ; then
    set -e
    git commit -m "${GIT_COMMIT_MESSAGE}

    skip-checks: true
    "
    git show
    echo "Changes committed to ${PUSH_BRANCH} branch."
else
    echo "There are no changes to commit to ${PUSH_BRANCH} branch when
    compared with origin/${DIFF_BRANCH}."
fi

set -e
