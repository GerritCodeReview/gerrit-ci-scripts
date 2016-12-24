#!/bin/bash -e

cd gerrit
. set-java.sh 8

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone"

bazel build $BAZEL_OPTS \
      plugins:core \
      release \
      gerrit-acceptance-framework:acceptance-framework \
      gerrit-acceptance-framework:acceptance-framework-src \
      gerrit-acceptance-framework:acceptance-framework-javadoc \
      gerrit-extension-api:extension-api \
      gerrit-extension-api:extension-api-src \
      gerrit-extension-api:extension-api-javadoc \
      gerrit-plugin-api:plugin-api \
      gerrit-plugin-api:plugin-api-src \
      gerrit-plugin-api:plugin-api-javadoc \
      gerrit-plugin-gwtui:gwtui-api \
      gerrit-plugin-gwtui:gwtui-api-src \
      gerrit-plugin-gwtui:gwtui-api-javadoc

mv $(find bazel-genfiles -name '*.war') bazel-genfiles/gerrit.war
