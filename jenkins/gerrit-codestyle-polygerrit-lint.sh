#!/bin/bash -xe

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

. set-java.sh 11

cd gerrit
bazelisk version
if ((git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q polygerrit-ui) || \
    (git show --summary HEAD | grep -q ^Merge:) || \
    (git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion))
then
  if [[ "$TARGET_BRANCH" == "master" ]]
  then
    echo 'Skipping PolyGerrit lint check on master'
  else
    echo 'Running PolyGerrit lint check...'
    java -fullversion
    bazelisk test //polygerrit-ui/app:lint_test
  fi
fi
