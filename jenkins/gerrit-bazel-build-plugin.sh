#!/bin/bash -e

git checkout -f gerrit/{branch}
rm -rf plugins/{name}
git read-tree -u --prefix=plugins/{name} origin/{branch}

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

  . set-java.sh 8

bazel build --ignore_unsupported_sandboxing -v 3 $TARGETS
