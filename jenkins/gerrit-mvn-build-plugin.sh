#!/bin/bash -e

. set-java.sh 8

if [ "{branch}" == "master" ] || [ "{branch}" == "stable-3.1" ] || [ "{branch}" == "stable-3.0" ] || [ "{branch}" == "stable-2.16" ] || [ "{branch}" == "stable-2.15" ] || [ "{branch}" == "stable-2.14" ]
then
  git checkout -f -b gerrit-master gerrit/{branch}
  git submodule update --init
  java -fullversion
  bazelisk version
  bazelisk build api
  ./tools/maven/api.sh install
fi

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
