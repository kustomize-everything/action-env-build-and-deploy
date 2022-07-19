#!/bin/bash

# Automatically add meta annotations at build-time
pushd "${ENV_DIR}" || exit 1
kustomize edit add annotation deployment-branch:"${DEPLOY_BRANCH}"
kustomize edit add annotation deployment-branch-url:"${DEPLOY_BRANCH_URL}"
kustomize edit add annotation deployment-repo:"${GITHUB_REPOSITORY}"
kustomize edit add annotation deployment-repo-url:"${DEPLOY_REPO_URL}"
kustomize edit add buildmetadata originAnnotations,managedByLabel
popd || exit 1

kustomize build --enable-helm "${ENV_DIR}" > /tmp/all.yaml

pushd /tmp || exit 1
yq -s '.kind + "-" + (.apiVersion | sub("\/", "_")) + "-" + .metadata.name' < all.yaml
rm all.yaml
popd || exit 1

# Must reset to clear build-time annotations
git reset --hard

if ! git ls-remote --exit-code --heads origin "${DEPLOY_BRANCH}"; then
  git checkout --orphan "${DEPLOY_BRANCH}"
  git rm -rf --ignore-unmatch '*'
  # Ensure that branch will not be polluted with unrendered YAML
  rm -rf base/ env/
  git commit --allow-empty -m "Initial Commit"
  git push origin "${DEPLOY_BRANCH}"
fi

# Base changes off the branch being deployed to
git checkout "${DEPLOY_BRANCH}" --

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
