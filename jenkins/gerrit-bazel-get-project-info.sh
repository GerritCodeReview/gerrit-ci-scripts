#!/bin/bash -e

curl -L https://gerrit-review.googlesource.com/projects/{project-name}/config | \
     tail -n +2 > bazel-genfiles/plugins/{name}/{name}.json

