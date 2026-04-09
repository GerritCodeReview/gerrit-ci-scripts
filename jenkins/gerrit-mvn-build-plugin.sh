#!/bin/bash -e

. set-java.sh --branch "{branch}"

git checkout -f -b gerrit-master gerrit/{branch}
git submodule update --init
java -fullversion

BAZEL_VERSION_OUTPUT=$(bazelisk version 2>/dev/null)
echo "$BAZEL_VERSION_OUTPUT"

# This is a workaround to Issue 316936462: after the initial build with $BAZEL_OPTS
# that include a remote cache, the subsequent implicit build commands executed would
# expect the cache to be remote and fail to download the artifact if the $BAZEL_OPTS
# are not passed. Because the 'bazel build' commands are dynamically generated, the
# only way to pass the extra parameters is via .bazelrc
if [[ "$BAZEL_OPTS" != "" ]]
then
  echo "build $BAZEL_OPTS" >> .bazelrc
fi

BAZEL_MAJOR=$(echo "$BAZEL_VERSION_OUTPUT" | sed -n 's/^Build label: \([0-9][0-9]*\).*/\1/p')
[ -n "$BAZEL_MAJOR" ] || BAZEL_MAJOR=0
if [ "$BAZEL_MAJOR" -ge 9 ]; then
  echo "Skipping bazel sync for Bazel $BAZEL_MAJOR"
else
  echo "Running bazel sync for Bazel $BAZEL_MAJOR"
  # Whilst all the rest of Gerrit is able to automatically sync the Bazel repositories
  # the PolyGerrit part fails to do so when the working directory is replaced with a
  # fresh clone from the remote Git repository
  bazelisk sync --only=npm --only=tools_npm --only=ui_npm --only=plugins_npm
fi

bazelisk build api
./tools/maven/api.sh install

git checkout -f origin/{branch}
mvn package

# Extract version information
PLUGIN_JARS=$(find . -name '{repo}*jar')
for jar in $PLUGIN_JARS
do
  PLUGIN_VERSION=$(git describe  --always origin/{branch})
  echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
  jar ufm $jar MANIFEST.MF && rm MANIFEST.MF

  echo "$PLUGIN_VERSION" > $jar-version

  curl -L https://gerrit-review.googlesource.com/projects/plugins%2F{repo}/config | \
     tail -n +2 > $(dirname $jar)/$(basename $jar .jar).json

done
