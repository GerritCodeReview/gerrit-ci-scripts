#!/bin/bash -e

git read-tree -u --prefix=gerrit gerrit/{branch}
. set-java.sh 8

cd gerrit
bazel build api
./tools/maven/api.sh install
