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

pushd /tmp || exit 1
# Invalid GitHub artifact path name characters: Double quote ", Colon :, Less than <, Greater than >, Vertical bar |, Asterisk *, Question mark ?
yq -s '.kind + "-" + (.apiVersion | sub("/", "_")) + "-" + (.metadata.name | sub("[:<>|*?/\\]", "_")) + ".yaml"' < all.yaml
rm all.yaml
popd || exit 1

# Must reset to clear build-time annotations
git reset --hard
