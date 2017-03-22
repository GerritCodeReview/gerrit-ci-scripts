#!/bin/bash -e

if [ "{branch}" == "master" ]
then
  git read-tree -u --prefix=gerrit gerrit/{branch}
  . set-java.sh 8

  pushd gerrit
  bazel build api
  ./tools/maven/api.sh install
  popd
fi

sbt -no-colors compile test assembly

# Extract version information
PLUGIN_JARS=$(find . -name '{name}*jar')
for jar in $PLUGIN_JARS
do
  PLUGIN_VERSION=$(git describe  --always origin/{branch})
  echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
  jar ufm $jar MANIFEST.MF && rm MANIFEST.MF

  echo "$PLUGIN_VERSION" > $jar-version
done
