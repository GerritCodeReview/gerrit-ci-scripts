#!/bin/bash -ex

cd gerrit

. set-java.sh 8

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

echo "Test with mode=$MODE"
echo '----------------------------------------------'

if [[ "$MODE" == *"reviewdb"* ]]
then
  runTests
fi

if [[ "$MODE" == *"notedbReadWrite"* ]]
then
  runTests '--test_env=GERRIT_NOTEDB=READ_WRITE'
fi

if [[ "$MODE" == *"polygerrit"* ]]
then
  if [ -z "$DISPLAY" ]
  then
    echo 'Not running local tests because env var "DISPLAY" is not set.'
  else
    echo 'Running local tests...'
    sh ./polygerrit-ui/app/run_test.sh
  fi
  if [ -z "$SAUCE_USERNAME" ] || [ -z "$SAUCE_ACCESS_KEY" ]
  then
    echo 'Not running on Sauce Labs because env vars are not set.'
  else
    echo 'Running tests on Sauce Labs...'
    WCT_ARGS='--plugin sauce' sh ./polygerrit-ui/app/run_test.sh
  fi
fi
