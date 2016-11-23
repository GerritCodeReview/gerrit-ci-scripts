#!/bin/bash -e

git checkout gerrit/{branch}
rm -rf plugins/{name}
git fetch https://gerrit.googlesource.com/plugins/{name} $REFS_CHANGE
git read-tree -u --prefix=plugins/{name} FETCH_HEAD

TARGETS=$(echo "{targets}" | sed -e 's/{{name}}/{name}/g')

. set-java.sh 8

bazel build --spawn_strategy=standalone --genrule_strategy=standalone -v 3 $TARGETS

