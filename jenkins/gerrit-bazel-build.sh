#!/bin/bash -e

cd gerrit
. set-java.sh 8

export BAZEL_OPTS="$BAZEL_OPTS"

java -fullversion
bazelisk version
bazelisk build $BAZEL_OPTS plugins:core release api
tools/maven/api.sh install
tools/eclipse/project.py --bazel bazelisk
