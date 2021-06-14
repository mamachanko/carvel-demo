#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

: "${APP_IMAGE:?}"
: "${BUNDLE_IMAGE:?}"
TAG="${1:?}"

onFailure() {
  printf "\n\x1b[1;4;31m#! carvel-demo | Building and pushing tag=%s failed\x1b[0m\n\n" "$TAG"
}

trap onFailure err

printf "\n\x1b[1;4;34m#! carvel-demo | Building and pushing tag=%s ...\x1b[0m\n\n" "$TAG"

# Create staging directory
PUBLISH="./staging/publish-$TAG"
rm -rf "$PUBLISH"
mkdir -p "$PUBLISH"/.imgpkg

ytt `# Render image configuration` \
  --file manifests \
  --data-value image="$APP_IMAGE" \
  --data-value-yaml tags="[$TAG]" \
  | kbld `# Build, push and resolve app image and write ImageLock to bundle` \
    --file - \
    --imgpkg-lock-output "$PUBLISH"/.imgpkg/images.yml

# Assemble bundle
cp \
  manifests/k8s.yml \
  manifests/values.yml \
  "$PUBLISH"/

cp \
  manifests/bundle.yml \
  "$PUBLISH"/.imgpkg/

# Push bundle
imgpkg push \
  --bundle "$BUNDLE_IMAGE:$TAG" \
  --file "$PUBLISH"

printf "\n\x1b[1;4;32m#! carvel-demo | Built and pushed tag=%s\x1b[0m\n\n" "$TAG"
