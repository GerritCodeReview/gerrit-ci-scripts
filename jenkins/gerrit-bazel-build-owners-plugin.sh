#!/bin/bash -e

git checkout -fb {branch} gerrit/{branch}
git submodule update --init
git read-tree -u --prefix=plugins/{name}-plugin origin/{branch}
ln -s plugins/{name}-plugin/owners-common .
pushd plugins && ln -s owners-plugin/{{owners,owners-autoassign}} . && popd

if [ -f plugins/{name}-plugin/external_plugin_deps.bzl ]
then
  cp -f plugins/{name}-plugin/external_plugin_deps.bzl plugins/
fi

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

. set-java.sh 8

java -fullversion
bazelisk version
bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS

for JAR in $(find bazel-bin/plugins/ -name {name}*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/{name}/$(basename $JAR-version)
done
