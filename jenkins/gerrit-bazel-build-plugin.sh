#!/bin/bash -e

git checkout -fb {branch} gerrit/{branch}
git submodule update --init
rm -rf plugins/{name}
git read-tree -u --prefix=plugins/{name} origin/{branch}
git fetch --tags origin

for file in external_plugin_deps.bzl package.json
do
  if [ -f plugins/{name}/$file ]
  then
    cp -f plugins/{name}/$file plugins/
  fi
done

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')
. set-java.sh 8

java -fullversion
bazelisk version
bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS
bazelisk test --test_env DOCKER_HOST=$DOCKER_HOST //tools/bzl:always_pass_test plugins/{name}/...

JAR="bazel-bin/plugins/{name}/{name}.jar"
if test -f $JAR
then
  jar xf $JAR META-INF/MANIFEST.MF
  sed '/Implementation-Version:/!d; s/.* //' < META-INF/MANIFEST.MF > bazel-bin/plugins/{name}/$(basename $JAR-version)
  rm -rf META-INF
fi