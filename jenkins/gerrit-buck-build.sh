#!/bin/bash -e

function buckConfig {
  grep "$1" .buckconfig  | cut -d '=' -f 2 | tr -d '[[:space:]]'
}

SOURCE_LEVEL=$(buckConfig "source_level")
TARGET_LEVEL=$(buckConfig "target_level")
. set-java.sh $(( $SOURCE_LEVEL > $TARGET_LEVEL ? $SOURCE_LEVEL : $TARGET_LEVEL ))

buck build -v 3 api plugins:core release

if [ -f tools/maven/api.sh ]
then
  # From Gerrit 2.13 onwards
  tools/maven/api.sh install
else
  # Up to Gerrit 2.12
  buck build -v 3 api_install
fi
mv $(find buck-out -name '*.war') buck-out/gen/gerrit.war
