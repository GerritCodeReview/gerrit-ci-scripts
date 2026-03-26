#!/bin/bash -e

curl https://review.gerrithub.io/projects/{organization}%2{repo}/config | tail -1 \
     > bazel-bin/plugins/{name}/{name}.json

