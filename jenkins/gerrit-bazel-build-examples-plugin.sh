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

EXAMPLES=( $(find * -depth 0 -type d -name 'example-*') )
popd

for EXAMPLE in "${{EXAMPLES[@]}}"
do
    for JAR in $(find "$PLUGIN_PATH"/bazel-bin/"$EXAMPLE" -name "$EXAMPLE".jar)
    do
        PLUGIN_VERSION=$(git describe  --always origin/{branch})
        echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
        jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
        DEST_JAR=bazel-bin/"$PLUGIN_PATH"/$(basename $JAR)
        [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
        echo "$PLUGIN_VERSION" > bazel-bin/"$PLUGIN_PATH"/$(basename $JAR-version)
    done
done
