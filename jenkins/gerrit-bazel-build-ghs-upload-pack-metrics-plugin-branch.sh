#!/bin/bash -e

. set-java.sh 17

git checkout -fb {branch} gerrit/{gerrit-branch}
git submodule update --init
git read-tree -u --prefix=plugins/{repo} origin/{branch}
git fetch --tags origin
pushd plugins && ln -s {repo}/components/collectors/gerrit/{name} . && popd

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

java -fullversion
bazelisk version
bazelisk build $TARGETS

for target in $TARGETS
do
    bazelisk test $target/... //tools/bzl:always_pass_test
done

for JAR in $(find bazel-bin/plugins/ -name {name}*.jar | egrep -e '(stamped|tests|header)' -v)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/{name}/$(basename $JAR-version)
done
