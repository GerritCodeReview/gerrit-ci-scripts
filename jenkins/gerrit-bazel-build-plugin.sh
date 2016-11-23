#!/bin/bash -e

if [ -f 'gerrit/BUILD' ]
then
  git checkout -f gerrit/{branch}
  rm -rf plugins/{name}
  git read-tree -u --prefix=plugins/{name} origin/{branch}

  TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

  . set-java.sh 8

  bazel build --spawn_strategy=standalone --genrule_strategy=standalone -v 3 $TARGETS

  for JAR in $(buck targets --show_output $TARGETS | awk '{{print $2}}')
  do
      PLUGIN_VERSION=$(git describe  --always origin/{branch})
      echo -e "Implementation-Version: $PLUGIN_VERSION" > MANIFEST.MF
      jar ufm $JAR MANIFEST.MF && rm MANIFEST.MF
      DEST_JAR=bazel-genfiles/plugins/{name}/$(basename $JAR)
      [ "$JAR" -ef "$DEST_JAR" ] || mv $JAR $DEST_JAR
      echo "$PLUGIN_VERSION" > bazel-genfiles/plugins/{name}/$(basename $JAR-version)
  done
fi
