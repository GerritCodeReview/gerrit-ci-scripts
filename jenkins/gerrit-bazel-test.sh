#!/bin/bash -e

cd gerrit

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone \
                 --test_output errors \
                 --test_summary detailed --flaky_test_attempts 3 \
                 --test_verbose_timeout_warnings --build_tests_only \
                 --nocache_test_results"

function runTests {
  echo ''
  echo 'Running slow tests serialized ...'
  echo ''
  bazel test $1 $BAZEL_OPTS --test_tag_filters=+slow,-elastic,-flaky --local_test_jobs 1 //...
  echo ''
  echo 'Running fast tests in parallel ...'
  bazel test $1 $BAZEL_OPTS --test_tag_filters=-slow,-elastic,-flaky --local_test_jobs 3 //...
  echo ''  
}

echo 'Test in default DB mode'
echo '----------------------------------------------'
runTests

echo 'Test in Note DB mode'
echo '----------------------------------------------'
runTests '--test_env=GERRIT_NOTEDB=READ_WRITE'

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
