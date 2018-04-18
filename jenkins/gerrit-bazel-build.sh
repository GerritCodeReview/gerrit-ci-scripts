#!/bin/bash -e

cd gerrit
. set-java.sh 8

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone"

bazel build $BAZEL_OPTS plugins:core release api
