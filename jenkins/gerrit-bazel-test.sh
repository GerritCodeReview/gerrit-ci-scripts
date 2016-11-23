#!/bin/bash -e

if [ -f "gerrit/BUILD" ]
then
  cd gerrit

  export BAZEL_OPTS="--ignore_unsupported_sandboxing --test_output errors \
                     --test_summary detailed --flaky_test_attempts 3 \
                     --test_verbose_timeout_warnings --build_tests_only \
                     --local_test_jobs 1"

  echo 'Test in default DB mode'
  echo '----------------------------------------------'
  bazel test $BAZEL_OPTS //...

  echo 'Test in Note DB mode'
  echo '----------------------------------------------'
  GERRIT_ENABLE_NOTEDB=TRUE bazel test $BAZEL_OPTS //...
fi

exit 0
