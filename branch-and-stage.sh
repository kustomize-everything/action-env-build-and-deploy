#!/bin/bash

# Output all commands
# set -x

# Show line numbers
# export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Base changes off the branch being deployed to
set +e
# If the branch exists, check it out
if git ls-remote --exit-code --heads origin "refs/heads/${ENV_BRANCH}"; then
  git checkout "${ENV_BRANCH}" --
else
# If the branch does not exist, create it
  git checkout --orphan "${ENV_BRANCH}" --
  git rm -rf --ignore-unmatch '*'
  set -e
  # Ensure that branch will not be polluted with unrendered YAML
  rm -rf base/ env/
  git commit --allow-empty -m "Initial Commit"
  git push origin "${ENV_BRANCH}"
fi
set -e

git checkout -B "${PUSH_BRANCH}" --

echo "Cleaning staging area..."
git rm -rf --ignore-unmatch '*'
# Ensure that branch will not be polluted with unrendered YAML
rm -rf base/ env/
# Ensure that untracked files are cleaned up
git clean -fd
echo "Post-staging cleanup status:"
git status
echo "Moving built k8s-manifests into staging area..."
cp /tmp/*.y*ml .
git add --all -fv ./*.y*ml
