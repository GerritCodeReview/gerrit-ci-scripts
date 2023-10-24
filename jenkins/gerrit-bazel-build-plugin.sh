#!/bin/bash -e

case {branch} in
  master|stable-3.9)
    . set-java.sh 17
    ;;

  *)
    . set-java.sh 11
    ;;
esac

git checkout -fb {branch} gerrit/{branch}
git submodule update --init
rm -rf plugins/{name}
git read-tree -u --prefix=plugins/{name} origin/{branch}
git fetch --tags origin

for file in external_plugin_deps.bzl external_package.json
do
  if [ -f plugins/{name}/$file ]
  then
    cp -f plugins/{name}/$file plugins/
  fi
done

PLUGIN_SCM_BASE_URL="https://gerrit.googlesource.com/a"
for extraPlugin in {extra-plugins}
do
    pushd ..
    git clone -b {branch} $PLUGIN_SCM_BASE_URL/plugins/$extraPlugin
    popd
    pushd plugins
    ln -s ../../$extraPlugin .
    popd
done
for extraModule in {extra-modules}
do
    pushd ..
    git clone -b {branch} $PLUGIN_SCM_BASE_URL/modules/$extraModule
    popd
    pushd plugins
    ln -s ../../$extraModule .
    popd
done

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

java -fullversion
bazelisk version
bazelisk build $BAZEL_OPTS $TARGETS
bazelisk test $BAZEL_OPTS --test_env DOCKER_HOST=$DOCKER_HOST //tools/bzl:always_pass_test plugins/{name}/...

for JAR in $(find bazel-bin/plugins/{name} -maxdepth 1 -name {name}*.jar)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/{name}/$(basename $JAR-version)
done
