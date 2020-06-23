#!/bin/bash -e

git checkout -fb {branch} gerrit/{gerrit-branch}
git submodule update --init
git read-tree -u --prefix=plugins/{name}-plugin origin/{branch}
git fetch --tags origin
ln -s plugins/{name}-plugin/owners-common .
pushd plugins && ln -s owners-plugin/{{owners,owners-autoassign}} . && popd

for file in external_plugin_deps.bzl package.json
do
  if [ -f plugins/{name}-plugin/$file ]
  then
    cp -f plugins/{name}-plugin/$file plugins/
  fi
done

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

. set-java.sh 8

java -fullversion
bazelisk version
bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS

for JAR in $(find bazel-bin/plugins/ -name {name}*.jar)
do
    jar xf $JAR META-INF/MANIFEST.MF
    sed '/Implementation-Version:/!d; s/.* //' < META-INF/MANIFEST.MF > bazel-bin/plugins/{name}/$(basename $JAR-version)
    rm -rf META-INF
done
