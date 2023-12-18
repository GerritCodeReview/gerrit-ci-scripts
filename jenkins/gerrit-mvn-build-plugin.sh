#!/bin/bash -e

case {branch} in
  master|stable-3.9)
    . set-java.sh 17
    ;;

  *)
    . set-java.sh 11
    ;;
esac

git checkout -f -b gerrit-master gerrit/{branch}
git submodule update --init
java -fullversion
bazelisk version

# This is a workaround to Issue 316936462: after the initial build with $BAZEL_OPTS
# that include a remote cache, the subsequent implicit build commands executed would
# expect the cache to be remote and fail to download the artifact if the $BAZEL_OPTS
# are not passed. Because the 'bazel build' commands are dynamically generated, the
# only way to pass the extra parameters is via .bazelrc
if [[ "$BAZEL_OPTS" != "" ]]
then
  echo "build $BAZEL_OPTS" >> .bazelrc
fi

# Whilst all the rest of Gerrit is able to automatically sync the Bazel repositories
# the PolyGerrit part fails to do so when the working directory is replaced with a
# fresh clone from the remote Git repository
bazelisk sync --only=npm --only=tools_npm --only=ui_npm --only=plugins_npm

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
