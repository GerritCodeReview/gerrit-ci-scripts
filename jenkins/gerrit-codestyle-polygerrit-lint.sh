#!/bin/bash -xe

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

. set-java.sh --branch "$TARGET_BRANCH"

cd gerrit
bazelisk version
if ((git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q polygerrit-ui) || \
    (git show --summary HEAD | grep -q ^Merge:) || \
    (git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion))
then
  echo 'Running PolyGerrit lint check...'
  java -fullversion
  GIT_TERMINAL_PROMPT=1 bazelisk test //polygerrit-ui/app:lint_test
  if [[ "$TARGET_BRANCH" == "master" ]]
  then
    GIT_TERMINAL_PROMPT=1 bazelisk test //polygerrit-ui/app:lit_analysis
  fi
fi
