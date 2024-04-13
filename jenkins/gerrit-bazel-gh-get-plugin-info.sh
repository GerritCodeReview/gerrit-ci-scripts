#!/bin/bash -e

curl -L https://api.github.com/repos/{organization}/{repo} \
     > bazel-bin/plugins/{name}/{name}.json

