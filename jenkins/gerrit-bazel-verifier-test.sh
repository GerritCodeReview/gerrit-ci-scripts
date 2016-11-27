#!/bin/bash -ex

if [ -f "gerrit/BUILD" ]
then
  cd gerrit

  . set-java.sh 8

  echo "Test with mode=$MODE"
  echo '----------------------------------------------'

  if [ "$MODE" == "notedb" ]
  then
    GERRIT_NOTEDB="--test_env=GERRIT_NOTEDB=READ_WRITE"
  fi

  if [ "$MODE" == "default" ] || [ "$MODE" == "notedb" ]
  then
    export BAZEL_NO_RUN='(elasticsearch|cookbook)'
    export BAZEL_TESTS=$(bazel test --check_tests_up_to_date //... | grep "NO STATUS" | awk '{print $1}' | egrep -v $BAZEL_NO_RUN)
    export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone \
                     --test_output errors \
                     --test_summary detailed --flaky_test_attempts 3 \
                     --test_verbose_timeout_warnings --build_tests_only \
                     --nocache_test_results"

    bazel test $GERRIT_NOTEDB $BAZEL_OPTS $BAZEL_TESTS
  fi

  if [ "$MODE" == "polygerrit" ]
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
fi
