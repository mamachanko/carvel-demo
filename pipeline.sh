#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

: "${APP_IMAGE:?}"
: "${BUNDLE_IMAGE:?}"

onFailure() {
  printf "\n\x1b[1;4;31m#! carvel-demo | Pipeline failed\x1b[0m\n\n"
}

trap onFailure err

TAG="${1:-$(./git-commit.sh)}"
PROMOTION_TAG="${2:-latest}"

printf "\n\x1b[1;4;34m#! carvel-demo | Running pipeline for tag=%s...\x1b[0m\n\n" "$TAG"

./build-and-push.sh "$TAG"
./consume.sh "$TAG"
./test.sh "$TAG"
./promote.sh "$TAG" "$PROMOTION_TAG"

printf "\n\x1b[1;4;32m#! carvel-demo | Pipeline passed. Tag=%s is now %s\x1b[0m\n\n" "$TAG" "$PROMOTION_TAG"
