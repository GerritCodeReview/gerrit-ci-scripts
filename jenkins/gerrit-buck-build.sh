#!/bin/bash -e

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
