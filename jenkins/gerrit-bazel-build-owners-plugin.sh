#!/bin/bash -e

git checkout -f gerrit/{branch}
git config user.name "Gerrit CI"
git config user.email "jenkins@gerritforge.com"
git fetch https://gerrit.googlesource.com/gerrit refs/changes/10/95610/1 && git cherry-pick FETCH_HEAD

rm -rf plugins/{name}
git read-tree -u --prefix=plugins/{name}-plugin origin/{branch}
pushd plugins && ln -s owners-plugin/owners* . && popd

if [ -f plugins/{name}-plugin/external_plugin_deps.bzl ]
then
  cp -f plugins/{name}-plugin/external_plugin_deps.bzl plugins/
fi

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

. set-java.sh 8

bazel build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS

for JAR in $(find bazel-genfiles/plugins/{name} -name {name}*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-genfiles/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-genfiles/plugins/{name}/$(basename $JAR-version)
done
