#!/bin/bash -e

git checkout origin/{branch}
git submodule update --init
rm -rf plugins/its-{name}
rm -rf plugins/its-base
git read-tree -u --prefix=plugins/its-{name} plugin/{branch}
git read-tree -u --prefix=plugins/its-base base/{branch}
git fetch --tags origin

rm -Rf bazel-bin

for file in external_plugin_deps.bzl package.json
do
  if [ -f plugins/its-{name}/$file ]
  then
    cp -f plugins/its-{name}/$file plugins/
  fi
done

TARGETS=$(echo "{targets}" | sed -e 's/its-{{name}}/its-{name}/g')

. set-java.sh 8

java -fullversion
bazelisk version
bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS
bazelisk test --test_env DOCKER_HOST=$DOCKER_HOST //tools/bzl:always_pass_test plugins/its-{name}/...

for JAR in $(find bazel-bin/plugins/its-{name} -name its-{name}*.jar)
do
    PLUGIN_VERSION=$(git describe --always plugin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/its-{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/its-{name}/$(basename $JAR-version)
done
