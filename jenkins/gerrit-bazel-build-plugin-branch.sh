#!/bin/bash -e

. set-java.sh 8

echo "Building plugin {name}/{branch} with Gerrit/{gerrit-branch}"

git remote add gerrit https://gerrit.googlesource.com/gerrit
git fetch gerrit {gerrit-branch} && git checkout -f FETCH_HEAD
git read-tree -u --prefix=plugins/{name} origin/{branch}

if [ -f plugins/{name}/external_plugin_deps.bzl ]
then
  cp -f plugins/{name}/external_plugin_deps.bzl plugins/
fi

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')
BUILD_TARGETS=$(echo "$TARGETS" | tr ' ' '\n' | grep -v test)

bazel build --spawn_strategy=standalone --genrule_strategy=standalone $BUILD_TARGETS

if TEST_TARGETS=$(echo "$TARGETS" | tr ' ' '\n' | grep test)
then
    BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone \
                   --test_output errors \
                   --test_summary detailed --flaky_test_attempts 3 \
                   --test_verbose_timeout_warnings --build_tests_only \
                   --test_timeout 3600 \
                   --test_tag_filters=-elastic,-flaky"
    bazel test $BAZEL_OPTS $TEST_TARGETS
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
