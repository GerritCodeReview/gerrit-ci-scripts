#!/bin/bash -xe
cd gerrit
bazelisk version
if ([ "$TARGET_BRANCH" == "master" ] || \
    [ "$TARGET_BRANCH" == "stable-3.1" ] || \
    [ "$TARGET_BRANCH" == "stable-3.0" ] || \
    [ "$TARGET_BRANCH" == "stable-2.16" ] || \
    [ "$TARGET_BRANCH" == "stable-2.15" ]) \
    && git show --diff-filter=AM --name-only --pretty="" HEAD | grep polygerrit-ui
then
  echo 'Running PolyGerrit lint check...'
  . set-java.sh 8
  bazelisk test //polygerrit-ui/app:lint_test --test_output errors
  bazelisk test //polygerrit-ui/app:polylint_test --test_output errors
fi
