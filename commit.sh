#!/bin/bash

if [ -z "${GIT_COMMIT_MESSAGE}" ]; then
    GIT_COMMIT_MESSAGE="${GIT_HEAD_COMMIT_MESSAGE}"
fi
echo "commit-message=${GIT_COMMIT_MESSAGE}" >> "${GITHUB_OUTPUT}"

set +e
if ! git diff --quiet "origin/${DIFF_BRANCH}" ; then
    set -e
    git commit -m "${GIT_COMMIT_MESSAGE}

    skip-checks: true
    "
    echo "Changes committed to ${PUSH_BRANCH} branch."
else
    echo "There are no changes to commit to ${PUSH_BRANCH} branch when
    compared with origin/${DIFF_BRANCH}."
fi

set -e
