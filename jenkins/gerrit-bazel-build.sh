#!/bin/bash -e

. set-java.sh 8

cd gerrit

echo "Build with mode=$MODE"
echo '----------------------------------------------'

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
  export BAZEL_REMOTE_OPTS=""
fi

if [[ "$MODE" == *"rbe"* ]]
then
  export BAZEL_OPTS="$BAZEL_OPTS $BAZEL_RBE_OPTS"
else
  export BAZEL_OPTS="$BAZEL_OPTS $BAZEL_REMOTE_OPTS"
fi

echo "BAZEL_OPTS is:"
echo $BAZEL_OPTS

java -fullversion
bazelisk version
bazelisk build $BAZEL_OPTS plugins:core release api
tools/maven/api.sh install
tools/eclipse/project.py --bazel bazelisk
