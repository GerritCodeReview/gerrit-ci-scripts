#!/bin/bash -e

cd gerrit
. set-java.sh 8

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone --java_toolchain //tools:error_prone_warnings_toolchain_bazel_0.16"

bazel build $BAZEL_OPTS //...
tools/eclipse/project.py
