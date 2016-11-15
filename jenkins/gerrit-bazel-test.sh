#!/bin/bash -e

if [ -f "gerrit/BUILD" ]
then
  echo 'Test in default DB mode'
  echo '----------------------------------------------'
  bazel test --test_output errors --test_summary detailed --flaky_test_attempts 3 --test_verbose_timeout_warnings --build_tests_only //...

  echo 'Test in Note DB mode'
  echo '----------------------------------------------'
  GERRIT_ENABLE_NOTEDB=TRUE bazel test --test_output errors --test_summary detailed --flaky_test_attempts 3 --test_verbose_timeout_warnings --build_tests_only //...
fi

exit 0
