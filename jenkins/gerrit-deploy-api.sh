#!/bin/bash -xe

cd gerrit 

VERSION=$(([ -f VERSION ] && grep VERSION VERSION) || ([ -f version.bzl ] && \
          grep VERSION version.bzl) || echo "")
if ! expr "$VERSION" : '.*SNAPSHOT.*'
then
  echo "Release build: not publishing the API to Snapshot Repository"
  exit 0
fi

if [ -f ~/.m2/settings.xml ]
then
  if grep -q sonatype-nexus-staging ~/.m2/settings.xml
  then
    echo "Deploying artifacts to Maven ..."
    ./tools/maven/api.sh deploy
    echo "DONE"
  fi
fi
