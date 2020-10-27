#!/bin/bash -xe

. set-java.sh 8

if [git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion]
then
  export BAZEL_OPTS=""
fi

cd gerrit
bazelisk version
if ([ "$TARGET_BRANCH" == "master" ] || \
    [ "$TARGET_BRANCH" == "stable-3.3" ] || \
    [ "$TARGET_BRANCH" == "stable-3.2" ]) && \
   ((git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q polygerrit-ui) || \
    (git show --summary HEAD | grep -q ^Merge:) || \
    (git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion))
then
  echo 'Running PolyGerrit lint check...'
  java -fullversion
  bazelisk test //polygerrit-ui/app:lint_test --test_output errors
  bazelisk test //polygerrit-ui/app:polylint_test --test_output errors
fi
