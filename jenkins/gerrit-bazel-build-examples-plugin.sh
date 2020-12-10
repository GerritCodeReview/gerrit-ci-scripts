#!/bin/bash -e

. set-java.sh 8

git checkout {branch}

java -fullversion
bazelisk version
bazelisk build all
