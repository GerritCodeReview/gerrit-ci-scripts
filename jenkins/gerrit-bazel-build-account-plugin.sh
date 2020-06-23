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
bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone $TARGETS
bazelisk test --test_env DOCKER_HOST=$DOCKER_HOST //tools/bzl:always_pass_test plugins/account/...

JAR="bazel-bin/plugins/account/account.jar"
if test -f $JAR
then
  jar xf $JAR META-INF/MANIFEST.MF
  sed '/Implementation-Version:/!d; s/.* //' < META-INF/MANIFEST.MF > bazel-bin/plugins/account/$(basename $JAR-version)
  rm -rf META-INF
fi
