#!/bin/bash -e

git remote add origin https://gerrit.googlesource.com/a/gerrit
git fetch origin
git checkout origin/{gerrit-branch}
git submodule update --init
rm -rf plugins/its-{name}
rm -rf plugins/its-base
git read-tree -u --prefix=plugins/its-{name} plugin/{branch}
git fetch --tags origin

# Try first the Gerrit-specific branch of its-base and then fallback to the one of the plugin
git read-tree -u --prefix=plugins/its-base base/{gerrit-branch} || git read-tree -u --prefix=plugins/its-base base/{branch}

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
    jar xf $JAR META-INF/MANIFEST.MF
    sed '/Implementation-Version:/!d; s/.* //' < META-INF/MANIFEST.MF > bazel-bin/plugins/its-{name}/$(basename $JAR-version)
    rm -rf META-INF
done
