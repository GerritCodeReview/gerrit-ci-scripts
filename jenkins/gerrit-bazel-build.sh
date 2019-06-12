#!/bin/bash -e

cd gerrit
. set-java.sh 8

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone --java_toolchain //tools:error_prone_warnings_toolchain"

bazelisk build $BAZEL_OPTS plugins:core release api
tools/eclipse/project.py --bazel bazelisk
