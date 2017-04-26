#!/bin/bash -e

if [ -f ~/.m2/settings.xml ]
then
  if grep -q sonatype-nexus-staging ~/.m2/settings.xml
  then
    echo "Deploying artifacts to Maven ..."
    cd gerrit && ./tools/maven/api.sh deploy
    echo "DONE"
  fi
fi
