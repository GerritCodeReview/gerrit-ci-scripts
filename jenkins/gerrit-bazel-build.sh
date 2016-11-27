#!/bin/bash -e

if [ -f "gerrit/BUILD" ]
then
  cd gerrit
  . set-java.sh 8

  export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone"

  bazel build $BAZEL_OPTS \
        gerrit-plugin-api:plugin-api_deploy.jar \
        gerrit-extension-api:extension-api_deploy.jar

  bazel build $BAZEL_OPTS plugins:core
  bazel build $BAZEL_OPTS release
fi
