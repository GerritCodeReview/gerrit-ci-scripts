#!/bin/bash -e

. set-java.sh 11

git checkout -fb {branch} gerrit/{branch}
git submodule update --init
rm -rf plugins/{name}
rm -rf plugins/pull-replication
git read-tree -u --prefix=plugins/{name} origin/{branch}
git read-tree -u --prefix=plugins/pull-replication origin/{branch}
git fetch --tags origin

for file in external_plugin_deps.bzl
do
  if [ -f plugins/{name}/$file ]
  then
    cp -f plugins/{name}/$file plugins/
  fi
done

TARGETS=$(echo "plugins/{name}:{name}" | sed -e 's/{name}/multi-site/g')

java -fullversion
bazelisk clean
bazelisk version
bazelisk build $BAZEL_OPTS $TARGETS
bazelisk test $BAZEL_OPTS --test_env DOCKER_HOST=$DOCKER_HOST plugins/multi-site:multi-site/...

for JAR in $(find bazel-bin/plugins/ -name {name}*.jar | egrep -e '(stamped|tests|header)' -v)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/{name}/$(basename $JAR-version)
done
