#!/bin/bash -e

cd gerrit
. set-java.sh 8

export BAZEL_OPTS="--javacopt=-Xep:ExpectedExceptionChecker:ERROR --spawn_strategy=standalone --genrule_strategy=standalone"

bazel build $BAZEL_OPTS //...
tools/eclipse/project.py
