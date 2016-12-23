#!/bin/bash -e

cd gerrit

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone \
                   --test_output errors \
                   --test_summary detailed --flaky_test_attempts 3 \
                   --test_verbose_timeout_warnings --build_tests_only \
                   --nocache_test_results \
                   --test_tag_filters=-elastic,-flaky"

echo 'Test in default DB mode'
echo '----------------------------------------------'
bazel test $BAZEL_OPTS //...

echo 'Test in Note DB mode'
echo '----------------------------------------------'
GERRIT_ENABLE_NOTEDB=TRUE bazel test $BAZEL_OPTS //...

echo 'Test PolyGerrit locally'
echo '----------------------------------------------'
sh ./polygerrit-ui/app/run_test.sh

if [ -z "$SAUCE_USERNAME" ] || [ -z "$SAUCE_ACCESS_KEY" ]
then
  echo 'Not running on Sauce Labs because env vars are not set.'
else
  echo 'Test PolyGerrit on Sauce Labs'
  echo '----------------------------------------------'
  WCT_ARGS='--plugin sauce' sh ./polygerrit-ui/app/run_test.sh
fi

exit 0
