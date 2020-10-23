#!/bin/bash -e

case "{branch}" in
  stable-2.16|stable-3.0|stable-3.1|stable-3.2)
    . set-java.sh 8
    ;;
  *)
    . set-java.sh 11
    ;;
esac

echo "Building plugin {name}/{branch} with Gerrit/{gerrit-branch}"

git remote add gerrit https://gerrit.googlesource.com/a/gerrit
git fetch gerrit {gerrit-branch}
git checkout -fb {gerrit-branch} gerrit/{gerrit-branch}
git submodule update --init
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
java -fullversion
bazelisk version
bazelisk build $BAZEL_OPTS --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS

TEST_TAG_FILTERS="-flaky"
if [ "{branch}" == "stable-2.16" ]
then
  TEST_TAG_FILTERS="$TEST_TAG_FILTERS,-elastic"
fi

BAZEL_OPTS="$BAZEL_OPTS --spawn_strategy=standalone --genrule_strategy=standalone \
                   --test_output errors \
                   --test_summary detailed --flaky_test_attempts 3 \
                   --test_verbose_timeout_warnings --build_tests_only \
                   --test_timeout 3600 \
                   --test_tag_filters=$TEST_TAG_FILTERS \
                   --test_env DOCKER_HOST=$DOCKER_HOST"
bazelisk test $BAZEL_OPTS //tools/bzl:always_pass_test plugins/{name}/...

for JAR in $(find bazel-bin/plugins/{name} -name {name}*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/{name}/$(basename $JAR-version)
done
