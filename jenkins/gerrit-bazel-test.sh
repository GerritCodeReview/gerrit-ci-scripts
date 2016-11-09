#!/bin/bash -e

echo 'Test in default DB mode'
echo '----------------------------------------------'
bazel test --build_tests_only --test_output errors --flaky_test_attempts 3 --test_verbose_timeout_warnings --build_tests_only //...

echo 'Test in Node DB mode'
echo '----------------------------------------------'
GERRIT_ENABLE_NOTEDB=TRUE bazel test --build_tests_only --test_output errors --flaky_test_attempts 3 --test_verbose_timeout_warnings --build_tests_only //...

exit 0
