#!/bin/bash -e
[ -f TEST_FAILED ] && echo "** TESTS FAILED **" && find ~/.cache/bazel -name '*.log' -exec cat {} \; && exit -1
