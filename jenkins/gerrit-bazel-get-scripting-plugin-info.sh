#!/bin/bash -e

curl -L https://gerrit-review.googlesource.com/projects/plugins%2Fscripting%2F{name}/config | \
     tail -n +2 > bazel-genfiles/plugins/{name}/{name}.json

