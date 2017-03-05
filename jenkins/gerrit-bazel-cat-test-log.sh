#!/bin/bash -e

find ~/.cache/bazel -name '*.log' -exec cat {} \;
