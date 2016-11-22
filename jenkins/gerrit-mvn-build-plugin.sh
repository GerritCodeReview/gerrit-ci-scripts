#!/bin/bash -e


if [ "{branch}" == "master" ]
then
  git read-tree -u --prefix=gerrit gerrit/{branch}
  SOURCE_LEVEL=$(grep "source_level" gerrit/.buckconfig || echo "source_level=7")
  . set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

  pushd gerrit
  buck build api
  ./tools/maven/api.sh install buck
  popd
fi

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
