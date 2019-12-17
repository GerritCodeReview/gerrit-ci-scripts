#!/bin/bash -xe
cd gerrit
if ([ "$TARGET_BRANCH" == "master" ] || \
    [ "$TARGET_BRANCH" == "stable-3.1" ] || \
    [ "$TARGET_BRANCH" == "stable-3.0" ] || \
    [ "$TARGET_BRANCH" == "stable-2.16" ]) \
    && git show --diff-filter=AM --name-only --pretty="" HEAD | grep polygerrit-ui
then
  echo 'Installing required npm packages...'
  YARN_OPTS=""
  if (git show --diff-filter=AM --name-only --pretty="" HEAD | grep package.json)
  then
    echo 'Detected changes to `package.json`. Updating dependencies from server.'
  else
    echo 'Installing dependencies from cache.'
    YARN_OPTS="$YARN_OPTS --offline"
  fi
  yarn install $YARN_OPTS
fi
