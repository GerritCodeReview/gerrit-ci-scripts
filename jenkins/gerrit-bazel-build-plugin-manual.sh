#!/bin/bash -e

if [ -f 'BUILD' ]
then
  git checkout gerrit/{branch}
  rm -rf plugins/{name}
  git fetch https://gerrit.googlesource.com/plugins/{name} $REFS_CHANGE
  git read-tree -u --prefix=plugins/{name} FETCH_HEAD

  TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

  . set-java.sh 8

  bazel build --spawn_strategy=standalone --genrule_strategy=standalone -v 3 $TARGETS

  for JAR in $(bazel targets --show_output $TARGETS | awk '{{print $2}}')
  do
      PLUGIN_VERSION=$(git describe  --always origin/{branch})
      echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
      jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF

      DEST_JAR=bazel-genfiles/plugins/{name}/$(basename $JAR)
      [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
      echo "$PLUGIN_VERSION" > bazel-genfiles/plugins/{name}/$(basename $JAR-version)
  done
fi
