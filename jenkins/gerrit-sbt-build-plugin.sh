#!/bin/bash -e

. set-java.sh --branch "{branch}"

java -fullversion
bazelisk version

git checkout -f -b gerrit-master gerrit/{branch}
git submodule update --init

bazel_config=""
if [ {branch} == "stable-3.11" ]; then
  echo -e "Set bazel_config to java21"
  bazel_config="--config=java21"
fi

bazelisk build "$bazel_config" api
./tools/maven/api.sh install "$bazel_config"

git checkout -f origin/{branch}
sbt -no-colors compile test assembly

# Extract version information
PLUGIN_JARS=$(find . -name '{name}*jar')
for jar in $PLUGIN_JARS
do
  PLUGIN_VERSION=$(git describe  --always origin/{branch})
  echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
  jar ufm $jar MANIFEST.MF && rm MANIFEST.MF

  echo "$PLUGIN_VERSION" > $jar-version

  curl -L https://gerrit-review.googlesource.com/projects/plugins%2F{name}/config | \
     tail -n +2 > $(dirname $jar)/$(basename $jar .jar).json
done
