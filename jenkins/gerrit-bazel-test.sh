#!/bin/bash -e

cd gerrit
. set-java.sh 8

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone \
                   --test_output errors \
                   --test_summary detailed --flaky_test_attempts 3 \
                   --test_verbose_timeout_warnings --build_tests_only \
                   --test_timeout 3600 \
                   --test_tag_filters=-flaky,-docker"

if [ "{branch}" == "stable-2.16" ] || [ "{branch}" == "stable-2.15" ] || [ "{branch}" == "stable-2.14" ]
then
  echo 'Test in ReviewDb mode'
  echo '----------------------------------------------'
  bazel test --test_env=GERRIT_NOTEDB=OFF $BAZEL_OPTS //...
fi

if [ "{branch}" == "master" ] || [ "{branch}" == "stable-2.16" ] || [ "{branch}" == "stable-2.15" ]
then
  echo 'Test in NoteDb mode'
  echo '----------------------------------------------'
  bazel test --test_env=GERRIT_NOTEDB=ON $BAZEL_OPTS //...
fi

if [ "{branch}" == "master" ] || [ "{branch}" == "stable-2.16" ] || [ "{branch}" == "stable-2.15" ] || [ "{branch}" == "stable-2.14" ]
then
  echo 'Test PolyGerrit locally'
  echo '----------------------------------------------'
  bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed

  if [ -z "$SAUCE_USERNAME" ] || [ -z "$SAUCE_ACCESS_KEY" ]
  then
    echo 'Not running on Sauce Labs because env vars are not set.'
  else
    echo 'Test PolyGerrit on Sauce Labs'
    echo '----------------------------------------------'
    WCT_ARGS='--plugin sauce' bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed
  fi
fi

exit 0
