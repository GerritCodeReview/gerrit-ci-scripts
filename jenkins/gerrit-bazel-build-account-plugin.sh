#!/bin/bash -e

case {branch} in
  master|stable-3.9)
    . set-java.sh 17
    ;;

  *)
    . set-java.sh 11
    ;;
esac

git checkout -f -b gerrit-{branch}  gerrit/{branch}
git submodule update --init
rm -rf plugins/account
git read-tree -u --prefix=plugins/account origin/{branch}

for file in external_plugin_deps.bzl external_package.json
do
  if [ -f plugins/account/$file ]
  then
    cp -f plugins/account/$file plugins/
  fi
done

TARGETS=$(echo "plugins/account:account" | sed -e 's/account/account/g')

# install packages from package.json and copy deps into src tree
pushd plugins/account
./copy_deps.sh
popd

java -fullversion
bazelisk version
bazelisk build $BAZEL_OPTS $TARGETS
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
