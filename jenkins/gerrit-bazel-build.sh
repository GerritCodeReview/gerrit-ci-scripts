#!/bin/bash -e

. set-java.sh 8

cd gerrit

echo "Build with mode=$MODE"
echo '----------------------------------------------'

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

java -fullversion
bazelisk version

if [[ "$MODE" == *"rbe"* ]]
then
    # TODO(davido): Figure out why javadoc part of api-rule doesn't work on RBE.
    # See: https://github.com/bazelbuild/bazel/issues/12765 for more background.
  bazelisk build --config=remote plugins:core release api-skip-javadoc
else
  bazelisk build $BAZEL_OPTS plugins:core release api
  tools/maven/api.sh install
  tools/eclipse/project.py --bazel bazelisk
fi
