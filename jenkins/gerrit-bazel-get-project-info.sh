#!/bin/bash -e

curl -L https://{project-info-host}/projects/{project-info-name}/config | \
     tail -n +2 > bazel-bin/plugins/{project-info-output}/{project-info-output}.json

