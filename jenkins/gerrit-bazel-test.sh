#!/bin/bash -e

rm -Rf plugins/*

echo 'Test in default DB mode'
echo '----------------------------------------------'
bazel test gerrit //...

echo 'Test in Node DB mode'
echo '----------------------------------------------'
GERRIT_ENABLE_NOTEDB=TRUE bazel test //...

exit 0
