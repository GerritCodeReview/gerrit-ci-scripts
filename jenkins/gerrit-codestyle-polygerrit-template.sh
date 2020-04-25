#!/bin/bash -xe
cd gerrit
if ([ "$TARGET_BRANCH" == "master" ] || \
    [ "$TARGET_BRANCH" == "stable-3.2" ] || \
    [ "$TARGET_BRANCH" == "stable-3.1" ] || \
    [ "$TARGET_BRANCH" == "stable-3.0" ] || \
    [ "$TARGET_BRANCH" == "stable-2.16" ]) \
    && git show --diff-filter=AM --name-only --pretty="" HEAD | grep polygerrit-ui
then
  echo 'Running PolyGerrit template test...'
  . set-java.sh 8
  java -fullversion
  bazelisk version
  bazelisk test //polygerrit-ui/app:all --test_tag_filters=template --test_output errors
fi
