#!/bin/bash -e

git checkout gerrit/{branch}
rm -rf plugins/its-{name}
rm -rf plugins/its-base
git read-tree -u --prefix=plugins/its-{name} origin/{branch}
git read-tree -u --prefix=plugins/its-base base/{branch}

rm -Rf bazel-genfiles
'
if [ -f plugins/its-{name}/external_plugin_deps.bzl ]
then
  cp -f plugins/its-{name}/external_plugin_deps.bzl plugins/
fi

. set-java.sh 8

bazel build --spawn_strategy=standalone --genrule_strategy=standalone plugins/its-{name}

JAR=$(ls $(pwd)/bazel-genfiles/plugins/its-{name}/its-{name}*.jar)
PLUGIN_VERSION=$(git describe  --always origin/{branch})
echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
DEST_JAR=bazel-genfiles/plugins/its-{name}/$(basename $JAR)
[ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
echo "$PLUGIN_VERSION" > bazel-genfiles/plugins/its-{name}/$(basename $JAR-version)
