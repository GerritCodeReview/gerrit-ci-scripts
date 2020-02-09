#!/bin/bash -xe
cd gerrit
if git show --diff-filter=AM --name-only --pretty="" HEAD | grep polygerrit-ui
then
  echo 'Installing required npm packages...'
  yarn install --offline || yarn install
fi
