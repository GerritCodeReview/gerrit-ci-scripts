#!/bin/bash -e


if [ "{branch}" == "master" ] || [ "{branch}" == "stable-3.0" ] || [ "{branch}" == "stable-2.16" ] || [ "{branch}" == "stable-2.15" ]
then
  git read-tree -u --prefix=gerrit gerrit/{branch}
  . set-java.sh 8

  pushd gerrit
  bazelisk version
  bazelisk build api
  ./tools/maven/api.sh install
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

  curl -L https://gerrit-review.googlesource.com/projects/plugins%2F{repo}/config | \
     tail -n +2 > $(dirname $jar)/$(basename $jar .jar).json

done
