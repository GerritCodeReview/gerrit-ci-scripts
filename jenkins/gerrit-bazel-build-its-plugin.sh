#!/bin/bash -e

git checkout gerrit/{branch}
rm -rf plugins/its-{name}
rm -rf plugins/its-base
git read-tree -u --prefix=plugins/its-{name} origin/{branch}
git read-tree -u --prefix=plugins/its-base base/{branch}

rm -Rf buck-out

. set-java.sh 8

bazel build --spawn_strategy=standalone --genrule_strategy=standalone -v 3 plugins/its-{name}

