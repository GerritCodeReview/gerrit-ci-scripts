#!/bin/bash -e

. set-java.sh 11

echo "Building plugin {name}/{branch} with Gerrit/{gerrit-branch}"

git remote show gerrit > /dev/null 2>&1 || git remote add gerrit https://gerrit.googlesource.com/a/gerrit
git fetch gerrit {gerrit-branch}
git checkout -fb {gerrit-branch} gerrit/{gerrit-branch}
git submodule update --init
git read-tree -u --prefix=plugins/{name} origin/{branch}
git fetch --tags origin

for file in external_plugin_deps.bzl external_package.json
do
  if [ -f plugins/{name}/$file ]
  then
    cp -f plugins/{name}/$file plugins/
  fi
done

PLUGIN_SCM_BASE_URL="https://gerrit.googlesource.com/a"
for extraPlugin in {extra-plugins}
do
    cd ..
    git clone -b {branch} $PLUGIN_SCM_BASE_URL/plugins/$extraPlugin
    cd gerrit/plugins
    ln -s ../../$extraPlugin .
    cd ..
done

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')
java -fullversion
bazelisk version
bazelisk build $BAZEL_OPTS $TARGETS

BAZEL_OPTS="$BAZEL_OPTS --flaky_test_attempts 3 \
                   --test_timeout 3600 \
                   --test_tag_filters=-flaky \
                   --test_env DOCKER_HOST=$DOCKER_HOST"
bazelisk test $BAZEL_OPTS //tools/bzl:always_pass_test plugins/{name}/...

for JAR in $(find bazel-bin/plugins/{name} -maxdepth 1 -name {name}*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/{name}/$(basename $JAR-version)
done
