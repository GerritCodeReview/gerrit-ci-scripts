#!/bin/bash -e

if [ -f "gerrit/BUILD" ]
then
  cd gerrit
  . set-java.sh 8

  bazel build --ignore_unsupported_sandboxing  \
        gerrit-plugin-api:plugin-api_deploy.jar \
        gerrit-extension-api:extension-api_deploy.jar
  bazel build --ignore_unsupported_sandboxing plugins:core
  bazel build --ignore_unsupported_sandboxing release
fi
