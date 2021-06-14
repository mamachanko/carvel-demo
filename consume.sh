#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

: "${BUNDLE_IMAGE:?}"
TAG="${1:?}"

onFailure() {
  printf "\n\x1b[1;4;31m#! carvel-demo | Consumption of tag=%s failed\x1b[0m\n\n" "$TAG"
}

trap onFailure err

printf "\n\x1b[1;4;34m#! carvel-demo | Consuming tag=%s ...\x1b[0m\n\n" "$TAG"

CONSUME="./staging/consume-$TAG"

rm -rf "$CONSUME"
mkdir "$CONSUME"

imgpkg pull \
  --bundle "$BUNDLE_IMAGE:$TAG" \
  --output "$CONSUME"

printf "\n\x1b[1;4;32m#! carvel-demo | Consumed tag=%s\x1b[0m\n\n" "$TAG"
