#!/bin/bash -e

curl -L https://gerrit-review.googlesource.com/projects/plugins%2Fits-{name}/config | \
     tail -1 > bazel-genfiles/plugins/its-{name}/its-{name}.json

