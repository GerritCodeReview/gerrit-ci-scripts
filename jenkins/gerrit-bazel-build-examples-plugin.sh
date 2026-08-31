#!/bin/bash -e

. set-java.sh --branch "{branch}"

git checkout {branch}

java -fullversion
bazelisk version
GIT_TERMINAL_PROMPT=1 bazelisk build all
