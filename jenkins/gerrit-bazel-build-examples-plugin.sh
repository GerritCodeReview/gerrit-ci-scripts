#!/bin/bash -e

git checkout {branch}

java -fullversion
bazelisk version
bazelisk build all
