#!/bin/bash -e

case {branch} in
  master|stable-3.11)
    . set-java.sh 21
    ;;

  stable-3.10|stable-3.9)
    . set-java.sh 17
    ;;

  *)
    . set-java.sh 11
    ;;
esac

git checkout -fb {branch} gerrit/{gerrit-branch}
git submodule update --init
git read-tree -u --prefix=plugins/{name}-plugin origin/{branch}
git fetch --tags origin
ln -s plugins/{name}-plugin/owners-common .
pushd plugins && ln -s owners-plugin/owners owners-plugin/owners-a* . && popd

for file in external_plugin_deps.bzl external_package.json
do
  if [ -f plugins/{name}-plugin/$file ]
  then
    cp -f plugins/{name}-plugin/$file plugins/
  fi
done

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

java -fullversion
bazelisk version
bazelisk build $TARGETS
for target in $TARGETS
do
    bazelisk test $target/... //tools/bzl:always_pass_test
done

for JAR in $(find bazel-bin/plugins/ -name {name}*.jar | egrep -e '(stamped|tests|header)' -v)
do
    PLUGIN_VERSION=$(git describe  --always origin/{branch})
    echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
    jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
    DEST_JAR=bazel-bin/plugins/{name}/$(basename $JAR)
    [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
    echo "$PLUGIN_VERSION" > bazel-bin/plugins/{name}/$(basename $JAR-version)
done
