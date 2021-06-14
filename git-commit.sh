#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

gitCommit() {
  # Gets a representation of the git commit for tagging:
  #  * If the workspace is on a Git tag, that tag is used, e.g. "v0.2.5"
  #  * If the workspace is on a Git commit, the short commit is used, e.g. "abcdefgh"
  #  * If the workspace has uncommitted changes, a -dirty suffix is appended, e.g. "v0.2.5-dirty" or "abcdefgh-dirty"
  #
  # (see: https://skaffold.dev/docs/pipeline-stages/taggers/#gitcommit-uses-git-commitsreferences-as-tags)

  local GIT_REV=""

  if [[ $(git tag) != '' ]]; then
    GIT_REV="$(git tag | head -n1)"
  else
    GIT_REV="$(git rev-parse --short @)"
  fi

  if [[ $(git status -s) != '' ]]; then
    echo "$GIT_REV-dirty"
  else
    echo "$GIT_REV"
  fi
}

gitCommit
