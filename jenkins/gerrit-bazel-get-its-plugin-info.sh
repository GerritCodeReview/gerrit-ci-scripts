#!/bin/bash -e

curl -L https://gerrit-review.googlesource.com/projects/plugins%2Fits-{name}/config | \
     tail -n +2 > bazel-genfiles/plugins/its-{name}/its-{name}.json

