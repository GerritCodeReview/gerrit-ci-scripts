#!/bin/bash -e

git checkout -f -b gerrit-{branch}  gerrit/{branch}
git submodule update --init
rm -rf plugins/account
git read-tree -u --prefix=plugins/account origin/{branch}

if [ -f plugins/account/external_plugin_deps.bzl ]
then
  cp -f plugins/account/external_plugin_deps.bzl plugins/
fi

TARGETS=$(echo "plugins/account:account" | sed -e 's/account/account/g')

. set-java.sh 8

export NODE_MODULES=$PWD/node_modules
npm install bower

pushd plugins/account
$NODE_MODULES/bower/bin/bower install
cp -Rf bower_components/jquery/dist/*js src/main/resources/static/js/.
cp -Rf bower_components/bootstrap/dist/js/*js src/main/resources/static/js/.
cp -Rf bower_components/bootstrap/dist/css/*css src/main/resources/static/css/.
cp -Rf bower_components/angular/*js src/main/resources/static/js/.
popd

java -fullversion
bazelisk version
bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS
bazelisk test --test_env DOCKER_HOST=$DOCKER_HOST plugins/account/...

for JAR in $(find bazel-bin/plugins/account -name account*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/account/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/account/$(basename $JAR-version)
done
