#!/bin/bash -e

sbt -no-colors {targets}

# Extract version information
JARS=$(find . -name '{name}*jar')
for jar in $JARS
do
  VERSION=$(git describe  --always origin/{branch})
  echo -e "Implementation-Version: $VERSION" > MANIFEST.MF
  jar ufm $jar MANIFEST.MF && rm MANIFEST.MF

  echo "$VERSION" > $jar-version

  curl -L https://gerrit-review.googlesource.com/projects/apps%2F{name}/config | \
     tail -n +2 > $(dirname $jar)/$(basename $jar .jar).json
done
