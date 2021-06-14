#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

TAG="${1:?}"

onFailure() {
  printf "\n\x1b[1;4;31m#! carvel-demo | Tests failed tag=%s\x1b[0m\n\n" "$TAG"
}

trap onFailure err

printf "\n\x1b[1;4;34m#! carvel-demo | Testing tag=%s...\x1b[0m\n\n" "$TAG"

# Create staging directory
CONSUME="./staging/consume-$TAG"

ytt `# Render k8s manifests with values` \
  --file "$CONSUME/k8s.yml" \
  --file "$CONSUME/values.yml" \
  | kbld `# Resolve image references with ImageLock` \
    --file - \
    --file "$CONSUME/.imgpkg/images.yml" \
    | kapp deploy `# Apply to cluster` \
      --diff-changes \
      --yes \
      --app "carvel-demo" \
      --file -

# Test deployment
# This is flakey, flakey. 🕺 Ideally, this would wait until a condition is met or time out.
sleep 5
curl -iv localhost:80

# Clean up
kapp delete \
  --yes \
  --app "carvel-demo"

printf "\n\x1b[1;4;32m#! carvel-demo | Tests passed tag=%s\x1b[0m\n\n" "$TAG"
