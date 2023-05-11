#!/bin/bash -e

. set-java.sh 11

java -fullversion
bazelisk version

git checkout -f origin/{branch}
sbt -no-colors compile test assembly

git checkout -f -b gerrit-master gerrit/{gerrit-branch}
git submodule update --init
git fetch --tags origin
bazelisk build api
./tools/maven/api.sh install

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
