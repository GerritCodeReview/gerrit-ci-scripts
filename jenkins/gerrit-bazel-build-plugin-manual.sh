#!/bin/bash -e

git checkout -fb {branch} gerrit/{branch}
git submodule update --init
rm -rf plugins/{name}
git fetch https://gerrit.googlesource.com/a/plugins/{name} $REFS_CHANGE
git read-tree -u --prefix=plugins/{name} FETCH_HEAD

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

for JAR in $(find bazel-bin/plugins/{name} -name {name}*.jar)
do
    jar xf $JAR META-INF/MANIFEST.MF
    sed '/Implementation-Version:/!d; s/.* //' < META-INF/MANIFEST.MF > bazel-bin/plugins/{name}/$(basename $JAR-version)
    rm -rf META-INF
done
