#!/bin/bash -e

. set-java.sh 8

git checkout {branch}

java -fullversion
bazelisk version
bazelisk build --spawn_strategy=standalone --genrule_strategy=standalone all
