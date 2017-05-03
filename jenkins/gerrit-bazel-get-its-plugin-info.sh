#!/bin/bash -e

curl -L https://gerrit-review.googlesource.com/projects/plugins/its-{name}/config | \
     tail -1 > bazel-genfiles/plugins/its-{name}/its-{name}.json

