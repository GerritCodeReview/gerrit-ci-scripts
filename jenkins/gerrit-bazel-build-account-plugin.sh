#!/bin/bash -e

git checkout -f gerrit/stable-2.16
rm -rf plugins/account
git read-tree -u --prefix=plugins/account origin/stable-2.16

if [ -f plugins/account/external_plugin_deps.bzl ]
then
  cp -f plugins/account/external_plugin_deps.bzl plugins/
fi

TARGETS=$(echo "plugins/{name}:{name}" | sed -e 's/{name}/account/g')
TEST_TARGET=$(grep -2 junit_tests plugins/account/BUILD | grep -o 'name = "[^"]*"' | cut -d '"' -f 2)

. set-java.sh 8

pushd plugins/account
npm install bower
./node_modules/bower/bin/bower install
cp -Rf bower_components/jquery/dist/* src/main/resources/static/js/.
cp -Rf bower_components/bootstrap/dist/js/* src/main/resources/static/js/.
cp -Rf bower_components/bootstrap/dist/css/* src/main/resources/static/css/.
popd

bazel build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS

if [ "$TEST_TARGET" != "" ]
then
    bazel test --test_env DOCKER_HOST=$DOCKER_HOST plugins/account:$TEST_TARGET
fi

for JAR in $(find bazel-genfiles/plugins/account -name account*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/stable-2.16)
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-genfiles/plugins/account/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-genfiles/plugins/account/$(basename $JAR-version)
done
