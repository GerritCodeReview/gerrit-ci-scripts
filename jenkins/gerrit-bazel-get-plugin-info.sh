#!/bin/bash -e

curl -L https://gerrit-review.googlesource.com/projects/plugins/{name}/config | \
     tail -1 > bazel-genfiles/plugins/{name}/{name}.json

