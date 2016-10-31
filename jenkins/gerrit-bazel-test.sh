#!/bin/bash -e

echo 'Test in default DB mode'
echo '----------------------------------------------'
bazel test --test_verbose_timeout_warnings gerrit //...

echo 'Test in Node DB mode'
echo '----------------------------------------------'
GERRIT_ENABLE_NOTEDB=TRUE bazel test --test_verbose_timeout_warnings //...

exit 0
