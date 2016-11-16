#!/bin/bash -ex

if [ -f "gerrit/BUILD" ]
then
  cd gerrit

  . set-java.sh 8

  echo 'Test with mode=$MODE'
  echo '----------------------------------------------'

  if [ "$MODE" == "notedb" ]
  then
    GERRIT_NOTEDB="--test_env=GERRIT_NOTEDB=READ_WRITE"
  fi

  if [ "$MODE" == "default" ] || [ "$MODE" == "notedb" ]
  then
    bazel test $GERRIT_NOTEDB \
               --ignore_unsupported_sandboxing --test_output errors \
               --test_summary detailed --flaky_test_attempts 3 \
               --test_verbose_timeout_warnings --build_tests_only //...
  fi

  if [ "$MODE" == "polygerrit" ]
  then
#    if [ -z "$DISPLAY" ]
#    then
#      echo 'Not running local tests because env var "DISPLAY" is not set.'
#    else
#      echo 'Running local tests...'
#      sh ./polygerrit-ui/app/run_test.sh
#    fi
#    if [ -z "$SAUCE_USERNAME" ] || [ -z "$SAUCE_ACCESS_KEY" ]
#    then
#      echo 'Not running on Sauce Labs because env vars are not set.'
#    else
#      echo 'Running tests on Sauce Labs...'
#      WCT_ARGS='--plugin sauce' sh ./polygerrit-ui/app/run_test.sh
#    fi
  fi
fi
