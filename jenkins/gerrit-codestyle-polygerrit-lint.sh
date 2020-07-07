#!/bin/bash -xe
cd gerrit
bazelisk version
if ([ "$TARGET_BRANCH" == "stable-3.1" ] || \
    [ "$TARGET_BRANCH" == "stable-3.0" ]) \
    && git show --diff-filter=AM --name-only --pretty="" HEAD | grep polygerrit-ui
then
  echo 'Running PolyGerrit lint check...'
  . set-java.sh 8
  java -fullversion
  bazelisk test //polygerrit-ui/app:lint_test --test_output errors
  bazelisk test //polygerrit-ui/app:polylint_test --test_output errors
fi
