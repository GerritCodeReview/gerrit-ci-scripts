#!/bin/bash -e

curl -L https://api.github.com/repos/{organization}/{name} \
     > bazel-genfiles/plugins/{name}/{name}.json

