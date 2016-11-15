#!/bin/bash -e

if [ -f "gerrit/BUILD" ]
then
  cd gerrit

  bazel build gerrit-plugin-api:plugin-api_deploy.jar gerrit-extension-api:extension-api_deploy.jar
  bazel build plugins:core
  bazel build release

  tools/maven/api.sh install bazel
fi
