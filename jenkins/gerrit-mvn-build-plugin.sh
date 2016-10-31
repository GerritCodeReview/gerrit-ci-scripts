#!/bin/bash -e

SOURCE_LEVEL=$(grep "source_level" gerrit/.buckconfig || echo "source_level=7")
. set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

if [ "{branch}" == "master" ]
then
  pushd gerrit
  buck build api
  ./tools/maven/api.sh install
  popd
fi

find . -type d -name 'target' -delete
mvn package

# Extract version information
PLUGIN_JARS=$(find . -name '{repo}*jar')
for jar in $PLUGIN_JARS
do
  PLUGIN_VERSION=$(git describe  --always origin/{branch})
  echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
  jar ufm $jar MANIFEST.MF && rm MANIFEST.MF

  echo "$PLUGIN_VERSION" > $jar-version
done
