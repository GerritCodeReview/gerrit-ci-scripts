#!/bin/bash -e

. set-java.sh --branch "{branch}"

git checkout {branch}

java -fullversion
bazelisk version
bazelisk build all
