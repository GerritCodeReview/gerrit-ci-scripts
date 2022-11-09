#!/bin/bash -xe

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

if [[ "{branch}" == "stable-3.4" ]]
then
  . set-java.sh 8
else
  . set-java.sh 11
fi

cd gerrit
bazelisk version
if ((git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q polygerrit-ui) || \
    (git show --summary HEAD | grep -q ^Merge:) || \
    (git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion))
then
  echo 'Running PolyGerrit lint check...'
  java -fullversion
  bazelisk test //polygerrit-ui/app:lint_test
  if [[ "$TARGET_BRANCH" == "master" ]]
  then
    bazelisk test //polygerrit-ui/app:lit_analysis
  fi
fi
