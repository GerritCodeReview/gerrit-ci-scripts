#!/bin/bash -e

case "{branch}" in
  stable-2.16|stable-3.2|stable-3.3|stable-3.4)
    . set-java.sh 8
    ;;
  *)
    . set-java.sh 11
    ;;
esac

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
  bazelisk build --config=remote --remote_instance_name=projects/api-project-164060093628/instances/default_instance plugins:core release api-skip-javadoc
else
  bazelisk build $BAZEL_OPTS plugins:core release api
  tools/maven/api.sh install
  tools/eclipse/project.py --bazel bazelisk
fi
