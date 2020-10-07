#!/bin/bash -e

git checkout -f -b gerrit-{branch}  gerrit/{branch}
git submodule update --init
rm -rf plugins/account
git read-tree -u --prefix=plugins/account origin/{branch}

for file in external_plugin_deps.bzl package.json
do
  if [ -f plugins/account/$file ]
  then
    cp -f plugins/account/$file plugins/
  fi
done

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
bazelisk build $BAZEL_OPTS--spawn_strategy=standalone --genrule_strategy=standalone $TARGETS
bazelisk test $BAZEL_OPTS --test_env DOCKER_HOST=$DOCKER_HOST //tools/bzl:always_pass_test plugins/account/...

for JAR in $(find bazel-bin/plugins/account -name account*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/account/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/account/$(basename $JAR-version)
done
