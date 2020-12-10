#!/bin/bash -e

. set-java.sh 8

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

java -fullversion
bazelisk version
bazelisk build $TARGETS

for JAR in $(find bazel-bin/plugins/{name} -name {name}*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF

    DEST_JAR=bazel-bin/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/{name}/$(basename $JAR-version)
done
