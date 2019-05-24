#!/bin/bash -e

cd gerrit
. set-java.sh 8

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone"

bazelisk version
bazelisk build $BAZEL_OPTS plugins:core release api
tools/eclipse/project.py --bazel bazelisk
