#!/bin/bash -e

git checkout -f gerrit/{branch}
rm -rf plugins/{name}
git read-tree -u --prefix=plugins/{name} origin/{branch}

if [ -f plugins/{name}/external_plugin_deps.bzl ]
then
  cp -f plugins/{name}/external_plugin_deps.bzl plugins/
fi

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')
TEST_TARGET=$(grep -2 junit_tests plugins/{name}/BUILD | grep -o 'name = "[^"]*"' | cut -d '"' -f 2)

. set-java.sh 8

bazel build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS

if [ "$TEST_TARGET" != "" ]
then
    bazel test plugins/{name}:$TEST_TARGET
fi

for JAR in $(find bazel-genfiles/plugins/{name} -name {name}*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-genfiles/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-genfiles/plugins/{name}/$(basename $JAR-version)
done
