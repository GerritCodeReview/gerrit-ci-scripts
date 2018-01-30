#!/bin/bash -e

git remote add gerrit https://gerrit.googlesource.com/gerrit
git fetch gerrit
git checkout gerrit/{gerrit-branch}
rm -rf plugins/its-{name}
rm -rf plugins/its-base
git read-tree -u --prefix=plugins/its-{name} origin/{branch}

# Try first the Gerrit-specific branch of its-base and then fallback to the one of the plugin
git read-tree -u --prefix=plugins/its-base base/{gerrit-branch} || git read-tree -u --prefix=plugins/its-base base/{branch}

rm -Rf bazel-genfiles

if [ -f plugins/its-{name}/external_plugin_deps.bzl ]
then
  cp -f plugins/its-{name}/external_plugin_deps.bzl plugins/
fi

. set-java.sh 8

bazel build --spawn_strategy=standalone --genrule_strategy=standalone plugins/its-{name}

# Remove duplicate entries
PLUGIN_JAR=$(ls $(pwd)/bazel-genfiles/plugins/its-{name}/its-{name}*.jar)
mkdir jar-out && pushd jar-out
jar xf $PLUGIN_JAR && rm -f $PLUGIN_JAR && jar cmf META-INF/MANIFEST.MF $PLUGIN_JAR .
popd

# Extract version information
PLUGIN_VERSION=$(git describe --always origin/{branch})
echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
jar ufm $PLUGIN_JAR MANIFEST.MF && rm MANIFEST.MF

echo "$PLUGIN_VERSION" > $PLUGIN_JAR-version
