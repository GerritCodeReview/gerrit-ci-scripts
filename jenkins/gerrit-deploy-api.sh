#!/bin/bash -e

VERSION=$(([ -f VERSION ] && cat VERSION) || ([ -f version.bzl ] && cat version.bzl) | grep VERSION)
if expr $VERSION : '.*SNAPSHOT.*'
then
  exit 0
fi

if [ -f ~/.m2/settings.xml ]
then
  if grep -q sonatype-nexus-staging ~/.m2/settings.xml
  then
    echo "Deploying artifacts to Maven ..."
    cd gerrit && ./tools/maven/api.sh deploy
    echo "DONE"
  fi
fi
