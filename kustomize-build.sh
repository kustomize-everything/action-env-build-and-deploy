#!/bin/bash

# Fail on non-zero exit
set -e

# Automatically add meta annotations at build-time
pushd "${ENV_DIR}" || exit 1
kustomize edit add annotation env-branch:"${ENV_BRANCH}"
kustomize edit add annotation env-branch-url:"${ENV_BRANCH_URL}"
kustomize edit add annotation deployment-repo:"${GITHUB_REPOSITORY}"
kustomize edit add annotation deployment-repo-url:"${DEPLOY_REPO_URL}"
kustomize edit add buildmetadata originAnnotations,managedByLabel
popd || exit 1

kustomize build --enable-helm "${ENV_DIR}" > /tmp/all.yaml
echo "/tmp/all contents:"
cat /tmp/all.yaml
pushd /tmp || exit 1
yq --version
yq -s '.kind + "-" + (.apiVersion | sub("\/", "_")) + "-" + .metadata.name' < all.yaml
echo "ls in /tmp after split:"
ls -a
rm all.yaml
popd || exit 1

# Must reset to clear build-time annotations
git reset --hard

set +e
if ! git ls-remote --exit-code --heads origin "${ENV_BRANCH}"; then
  set -e
  git checkout --orphan "${ENV_BRANCH}"
  git rm -rf --ignore-unmatch '*'
  # Ensure that branch will not be polluted with unrendered YAML
  rm -rf base/ env/
  git commit --allow-empty -m "Initial Commit"
  git push origin "${ENV_BRANCH}"
fi

set -e
# Base changes off the branch being deployed to
git checkout "${ENV_BRANCH}" --

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
