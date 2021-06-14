#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

: "${BUNDLE_IMAGE:?}"
TAG="${1:?}"
PROMOTION_TAG="${2:?}"

onFailure() {
  printf "\n\x1b[1;4;31m#! carvel-demo | Promotion of tag=%s to %s failed\x1b[0m\n\n" "$TAG" "$PROMOTION_TAG"
}

trap onFailure err

# Fail if the tag is dirty.
if echo "$TAG" | grep -q '\-dirty'; then
  printf "\n\x1b[1;4;31m#! carvel-demo | Promotion of dirty tag=%s to %s is disabled\x1b[0m\n\n" "$TAG" "$PROMOTION_TAG"
  false
fi

printf "\n\x1b[1;4;34m#! carvel-demo | Promoting tag=%s to %s...\x1b[0m\n\n" "$TAG" "$PROMOTION_TAG"

# Push with promoted tag
# (Should this use `imgpkg copy` instead?)
imgpkg push \
  --bundle "$BUNDLE_IMAGE:$PROMOTION_TAG" \
  --file "./staging/consume-$TAG"

printf "\n\x1b[1;4;32m#! carvel-demo | Promoted tag=%s to %s\x1b[0m\n\n" "$TAG" "$PROMOTION_TAG"
