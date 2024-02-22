#!/bin/bash -e

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  echo "Bazel version upgrade to $(cat .bazelversion) detected => cleaning up all local Bazel caches"
  rm -Rf ~/.gerritcodereview ~/.cache
fi
