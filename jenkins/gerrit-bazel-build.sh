#!/bin/bash -e

if [ -f "gerrit/BUILD" ]
then
  cd gerrit
  . set-java.sh 8

  export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone"

  bazel build $BAZEL_OPTS -v 3 api plugins:core release

  if [ -f tools/maven/api.sh ]
  then
    # From Gerrit 2.13 onwards
    tools/maven/api.sh install bazel
  fi

  mv $(find bazel-genfiles -name '*.war') bazel-genfiles/gerrit.war
fi
