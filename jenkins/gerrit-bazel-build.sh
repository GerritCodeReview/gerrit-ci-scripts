#!/bin/bash -e

bazel build release
bazel build gerrit-plugin-api:plugin-api_deploy.jar gerrit-extension-api:extension-api_deploy.jar 
bazel build plugins:core
