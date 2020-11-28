#!/bin/bash -e

case "{branch}" in
  stable-2.16|stable-3.0|stable-3.1|stable-3.2)
    . set-java.sh 8
    ;;
  *)
    . set-java.sh 11
    ;;
esac

java -fullversion
bazelisk version

git checkout -f -b gerrit-master gerrit/{branch}
git submodule update --init
bazelisk build api
./tools/maven/api.sh install

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
