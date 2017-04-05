#!/bin/bash -e

cd gerrit
. set-java.sh 8

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone"

bazel build $BAZEL_OPTS \
      gerrit-plugin-api:plugin-api_deploy.jar \
      gerrit-extension-api:extension-api_deploy.jar

if [ -f ~/.m2/settings.xml ]
then
  if grep -q sonatype-nexus-staging ~/.m2/settings.xml
  then
    echo "Deploying artifacts to Maven ..."
    /tools/maven/api.sh deploy
    echo "DONE"
  fi
fi

bazel build $BAZEL_OPTS plugins:core
bazel build $BAZEL_OPTS release
