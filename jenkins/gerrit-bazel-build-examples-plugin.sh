#!/bin/bash -e

PLUGIN_PATH=plugins/{name}

git checkout -fb {branch} gerrit/{branch}
git submodule update --init
rm -rf "$PLUGIN_PATH"
git read-tree -u --prefix=$PLUGIN_PATH origin/{branch}

if [ -f "$PLUGIN_PATH"/external_plugin_deps.bzl ]
then
  cp -f "$PLUGIN_PATH"/external_plugin_deps.bzl plugins/
fi

. set-java.sh 8

pushd "$PLUGIN_PATH"
java -fullversion
bazelisk version
bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone all
popd