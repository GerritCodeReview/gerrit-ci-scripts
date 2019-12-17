#!/bin/bash -xe
cd gerrit
if ([ "$TARGET_BRANCH" == "master" ] || \
    [ "$TARGET_BRANCH" == "stable-3.1" ] || \
    [ "$TARGET_BRANCH" == "stable-3.0" ] || \
    [ "$TARGET_BRANCH" == "stable-2.16" ]) \
    && git show --diff-filter=AM --name-only --pretty="" HEAD | grep polygerrit-ui
then
  echo 'Installing required npm packages...'
  yarn install --offline || yarn install
fi
