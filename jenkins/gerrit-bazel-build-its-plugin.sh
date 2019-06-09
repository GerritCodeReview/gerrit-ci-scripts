#!/bin/bash -e

git checkout gerrit/{branch}
rm -rf plugins/its-{name}
rm -rf plugins/its-base
git read-tree -u --prefix=plugins/its-{name} origin/{branch}
git read-tree -u --prefix=plugins/its-base base/{branch}

rm -Rf bazel-bin

if [ -f plugins/its-{name}/external_plugin_deps.bzl ]
then
  cp -f plugins/its-{name}/external_plugin_deps.bzl plugins/
fi

TARGETS=$(echo "{targets}" | sed -e 's/its-{{name}}/its-{name}/g')
TEST_TARGET=$(grep -2 junit_tests plugins/its-{name}/BUILD | grep -o 'name = "[^"]*"' | cut -d '"' -f 2)

. set-java.sh 8

bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS

if [ "$TEST_TARGET" != "" ]
then
    bazelisk test --test_env DOCKER_HOST=$DOCKER_HOST plugins/its-{name}:$TEST_TARGET
fi

for JAR in $(find bazel-bin/plugins/its-{name} -name its-{name}*.jar)
do
    PLUGIN_VERSION=$(git describe --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/its-{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/its-{name}/$(basename $JAR-version)
done

