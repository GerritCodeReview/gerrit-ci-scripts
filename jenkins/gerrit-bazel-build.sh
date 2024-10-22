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
case $TARGET_BRANCH in
  master|stable-3.11)
    . set-java.sh 21
    ;;

  stable-3.10|stable-3.9)
    . set-java.sh 17
    ;;

  *)
    . set-java.sh 11
    ;;
esac

echo "Build with mode=$MODE"
echo '----------------------------------------------'

java -fullversion
bazelisk version

# Whilst all the rest of Gerrit is able to automatically sync the Bazel repositories
# the PolyGerrit part fails to do so when the working directory is replaced with a
# fresh clone from the remote Git repository
bazelisk sync --only=npm --only=tools_npm --only=ui_npm --only=plugins_npm

if [[ "$MODE" == *"rbe"* ]]
then
  bazelisk build --config=remote_bb --jobs=50 --remote_header=x-buildbuddy-api-key=$BB_API_KEY plugins:core release api
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

  bazelisk build plugins:core release api
  tools/maven/api.sh install
  tools/eclipse/project.py --bazel bazelisk
fi
