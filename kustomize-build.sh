#!/bin/bash

# Fail on non-zero exit
set -e

# Output all commands
set -x

# Show line numbers
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Automatically add meta annotations at build-time
pushd "${ENV_DIR}" || exit 1
kustomize edit add annotation env-branch:"${ENV_BRANCH}"
kustomize edit add annotation env-branch-url:"${ENV_BRANCH_URL}"
kustomize edit add annotation deployment-repo:"${GITHUB_REPOSITORY}"
kustomize edit add annotation deployment-repo-url:"${DEPLOY_REPO_URL}"
kustomize edit add buildmetadata originAnnotations,managedByLabel
popd || exit 1

kustomize build --enable-helm "${ENV_DIR}" > /tmp/all.yaml

pushd /tmp || exit 1
# Invalid GitHub artifact path name characters: Double quote ", Colon :, Less than <, Greater than >, Vertical bar |, Asterisk *, Question mark ?
yq -s '.kind + "-" + (.apiVersion | sub("/", "_")) + "-" + (.metadata.name | sub("[:<>|*?/\\]", "_")) + ".yaml"' < all.yaml
rm all.yaml
popd || exit 1

# Must reset to clear build-time annotations
git reset --hard

# Base changes off the branch being deployed to
set +e
# If the branch exists, check it out
if git show-ref --verify --quiet "refs/heads/${ENV_BRANCH}"; then
  git checkout "${ENV_BRANCH}" --
else
# If the branch does not exist, create it
  git checkout --orphan "${ENV_BRANCH}" --
  git rm -rf --ignore-unmatch '*'
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
echo "Post-staging cleanup status:"
git status
echo "Moving built k8s-manifests into staging area..."
cp /tmp/*.y*ml .
git add --all -fv ./*.y*ml
