#!/bin/bash -xe

case "{branch}" in
  stable-3.3|stable-3.4)
    . set-java.sh 8
    ;;
  *)
    . set-java.sh 11
    ;;
esac

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

cd gerrit
bazelisk version
if ((git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q polygerrit-ui) || \
    (git show --summary HEAD | grep -q ^Merge:) || \
    (git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion))
then
  echo 'Running PolyGerrit lint check...'
  java -fullversion
  bazelisk test //polygerrit-ui/app:lint_test
  bazelisk test //polygerrit-ui/app:polylint_test
fi
