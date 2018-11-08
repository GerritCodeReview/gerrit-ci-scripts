#!/bin/bash -e

cd gerrit

SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
. set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

buck build -v 3 api plugins:core release

tools/maven/api.sh install buck

mv $(find buck-out -name '*.war') buck-out/gen/gerrit.war
