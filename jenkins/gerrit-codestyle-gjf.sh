#!/bin/bash -xe
cd gerrit
echo 'Running google-java-format check...'
git show --diff-filter=AM --name-only --pretty="" HEAD | grep java$ | xargs -r bazelisk run --run_under="cd $PWD &&" tools:gjf -- -n --set-exit-if-changed
