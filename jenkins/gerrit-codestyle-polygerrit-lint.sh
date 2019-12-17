#!/bin/bash -xe
cd gerrit
bazelisk version
if ([ "$TARGET_BRANCH" == "master" ] || \
    [ "$TARGET_BRANCH" == "stable-3.1" ] || \
    [ "$TARGET_BRANCH" == "stable-3.0" ] || \
    [ "$TARGET_BRANCH" == "stable-2.16" ]) \
    && git show --diff-filter=AM --name-only --pretty="" HEAD | grep polygerrit-ui
then
  echo 'Running PolyGerrit lint check...'
  . set-java.sh 8
  java -fullversion
  yarn eslint
  yarn polylint
fi
