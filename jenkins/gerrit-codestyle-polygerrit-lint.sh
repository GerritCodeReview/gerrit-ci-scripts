#!/bin/bash -xe

. set-java.sh 8

cd gerrit
bazelisk version
if ([ "$TARGET_BRANCH" == "master" ] || \
    [ "$TARGET_BRANCH" == "stable-3.3" ] || \
    [ "$TARGET_BRANCH" == "stable-3.2" ] || \
    [ "$TARGET_BRANCH" == "stable-3.1" ] || \
    [ "$TARGET_BRANCH" == "stable-3.0" ] || \
    [ "$TARGET_BRANCH" == "stable-2.16" ]) && \
   ((git show --diff-filter=AM --name-only --pretty="" HEAD | grep polygerrit-ui) || \
    (git show --summary HEAD | grep -q ^Merge:))
then
  echo 'Running PolyGerrit lint check...'
  java -fullversion
  bazelisk test //polygerrit-ui/app:lint_test --test_output errors
  bazelisk test //polygerrit-ui/app:polylint_test --test_output errors
fi
