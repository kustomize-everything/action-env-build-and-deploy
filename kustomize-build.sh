#!/bin/bash

source "${GITHUB_ACTION_PATH}/util.sh"

# Fail on non-zero exit
set -e

# Generate dir in /tmp for kustomize to store the render
RENDER_DIR=$(mktemp -d)
RENDER_FILE="${RENDER_DIR}/all.yaml"

if is_debug; then
  echo "[debug] RENDER_DIR=${RENDER_DIR}"
  echo "[debug] RENDER_FILE=${RENDER_FILE}"
  echo "[debug] ls ${RENDER_DIR} pre-kustomize:"
  ls -la "${RENDER_DIR}"
fi

# Automatically add meta annotations at build-time
pushd "${ENV_DIR}" || exit 1
kustomize edit add annotation env-branch:"${ENV_BRANCH}"
kustomize edit add annotation env-branch-url:"${ENV_BRANCH_URL}"
kustomize edit add annotation deployment-repo:"${GITHUB_REPOSITORY}"
kustomize edit add annotation deployment-repo-url:"${DEPLOY_REPO_URL}"
kustomize edit add buildmetadata originAnnotations,managedByLabel
popd || exit 1

kustomize build --enable-helm "${ENV_DIR}" > "${RENDER_FILE}"

if is_debug; then
  echo "[debug] ls ${RENDER_DIR} post-kustomize"
  ls -la "${RENDER_DIR}"
fi


pushd "${RENDER_DIR}" || exit 1
# If the render file is not empty
if [[ -s "${RENDER_FILE}" ]]; then
  # Split the rendered file into individual files for each resource
  # Invalid GitHub artifact path name characters: Double quote ", Colon :, Less than <, Greater than >, Vertical bar |, Asterisk *, Question mark ?
  yq -s '.kind + "-" + (.apiVersion | sub("/", "_")) + "-" + (.metadata.name | sub("[:<>|*?/]", "_")) + ".yaml"' < "${RENDER_FILE}"

  if is_debug; then
    echo "[debug] ls ${RENDER_DIR} post-yq"
    ls -la "${RENDER_DIR}"
  fi
else
  echo "[WARN] ${RENDER_FILE} is empty"
fi
# Always cleanup the render file
rm "${RENDER_FILE}"
popd || exit 1

# Must reset to clear build-time annotations
git reset --hard

# Export RENDER_DIR for downstream steps using new GH action output syntax
echo "RENDER_DIR=${RENDER_DIR}" >> "${GITHUB_ENV}"
