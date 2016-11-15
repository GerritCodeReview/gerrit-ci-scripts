#!/bin/bash -e
set +x


if [ -f "gerrit/BUILD" ]
then
  cd gerrit

  SOURCE_LEVEL=$(grep "source_level" .buckconfig || echo "source_level=7")
  . set-java.sh $(echo $SOURCE_LEVEL | cut -d '=' -f 2 | tr -d '[[:space:]]')

  echo 'Test with mode={mode}'
  echo '----------------------------------------------'

  rm -Rf plugins/*

  if [ "{mode}" == "notedb" ]
  then
    export GERRIT_ENABLE_NOTEDB=TRUE
  fi

  if [ "{mode}" == "default" ] || [ "{mode}" == "notedb" ]
  then
    bazel test --test_output errors --test_summary detailed --flaky_test_attempts 3 --test_verbose_timeout_warnings --build_tests_only //...
  fi

  if [ "{mode}" == "polygerrit" ]
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
