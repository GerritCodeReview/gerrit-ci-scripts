#!/bin/bash -e

curl -L https://api.github.com/repos/{organization}/{name} \
     > bazel-bin/plugins/{name}/{name}.json

