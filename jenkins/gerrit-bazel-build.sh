#!/bin/bash -e

. set-java.sh 8

cd gerrit

echo "Build with mode=$MODE"
echo '----------------------------------------------'

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

if [[ "$MODE" == *"rbe"* ]]
then
  export BAZEL_OPTS="$BAZEL_RBE_OPTS"
fi

java -fullversion
bazelisk version
bazelisk build $BAZEL_OPTS plugins:core release api

if [[ "$MODE" != *"rbe"* ]]
then
  tools/maven/api.sh install
  tools/eclipse/project.py --bazel bazelisk
fi
