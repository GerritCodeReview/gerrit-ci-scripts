#!/bin/bash -e

cd gerrit

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

if [[ "$TARGET_BRANCH" == "" ]]
then
  TARGET_BRANCH={branch}
fi
. set-java.sh --branch "$TARGET_BRANCH"

echo "Build with mode=$MODE"
echo '----------------------------------------------'

java -fullversion
bazelisk version

# Whilst all the rest of Gerrit is able to automatically sync the Bazel repositories
# the PolyGerrit part fails to do so when the working directory is replaced with a
# fresh clone from the remote Git repository
bazelisk sync --only=npm --only=tools_npm --only=ui_npm --only=plugins_npm

COMMON_RBE_BAZEL_OPTS="--jobs=50 --remote_header=x-buildbuddy-api-key=$BB_API_KEY"
if [[ "$MODE" == *"rbe"* ]]
then
  if [[ "$TARGET_BRANCH" == "stable-3.11" ]]
  then
    bazelisk build --config=remote21_bb "$COMMON_RBE_BAZEL_OPTS" plugins:core release api
  else
    # Default config for other branches
    bazelisk build --config=remote_bb "$COMMON_RBE_BAZEL_OPTS" plugins:core release api
  fi
elif [[ "$MODE" == *"polygerrit"* ]]
then
  echo "Skipping building eclipse and maven"
else
  # This is a workaround to Issue 316936462: after the initial build with $BAZEL_OPTS
  # that include a remote cache, the subsequent implicit build commands executed would
  # expect the cache to be remote and fail to download the artifact if the $BAZEL_OPTS
  # are not passed. Because the 'bazel build' commands are dynamically generated, the
  # only way to pass the extra parameters is via user.bazelrc
  if [[ "$BAZEL_OPTS" != "" ]]
  then
    for bazelopt in `echo $BAZEL_OPTS | xargs`
    do
      echo "build $bazelopt" >> user.bazelrc
    done
  fi

  bazel_config=""
  if [ "$TARGET_BRANCH" == "stable-3.11" ]; then
    echo -e "Set bazel_config to java21"
    bazel_config="--config=java21"
  fi

  bazelisk build "$bazel_config" plugins:core release api
  tools/maven/api.sh install "$bazel_config"
  tools/eclipse/project.py --bazel bazelisk
fi
