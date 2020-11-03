#!/bin/bash -e

. set-java.sh 8

cd gerrit

if [git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion]
then
  export BAZEL_OPTS=""
fi

export BAZEL_OPTS="$BAZEL_OPTS --spawn_strategy=standalone --genrule_strategy=standalone"

java -fullversion
bazelisk version
bazelisk build $BAZEL_OPTS plugins:core release api
tools/maven/api.sh install
tools/eclipse/project.py --bazel bazelisk
