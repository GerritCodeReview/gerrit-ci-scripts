#!/bin/bash -e

curl -L https://gerrit-review.googlesource.com/projects/plugins%2F{name}/config | \
     tail -1 > bazel-genfiles/plugins/{name}/{name}.json

