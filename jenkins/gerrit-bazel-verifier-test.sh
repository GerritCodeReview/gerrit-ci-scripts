#!/bin/bash -ex

cd gerrit

. set-java.sh 8

echo "Test with mode=$MODE"
echo '----------------------------------------------'

export BAZEL_OPTS="$BAZEL_OPTS --spawn_strategy=standalone --genrule_strategy=standalone \
                 --test_output errors \
                 --test_summary detailed --flaky_test_attempts 3 \
                 --test_verbose_timeout_warnings --build_tests_only \
                 --test_timeout 3600 \
                 --test_tag_filters=-flaky \
                 --test_env DOCKER_HOST=$DOCKER_HOST"

java -fullversion
bazelisk version

if [[ "$MODE" == *"reviewdb"* ]]
then
  GERRIT_NOTEDB="--test_env=GERRIT_NOTEDB=OFF"
  bazelisk test $BAZEL_OPTS //...
fi

if [[ "$MODE" == *"notedb"* ]]
then
  GERRIT_NOTEDB="--test_env=GERRIT_NOTEDB=ON"
  bazelisk test $GERRIT_NOTEDB $BAZEL_OPTS //...
fi

if [[ "$MODE" == *"polygerrit"* ]]
then
  if [ -z "$DISPLAY" ]
  then
    echo 'Not running local tests because env var "DISPLAY" is not set.'
  else
    echo 'Running local tests...'
    bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed
  fi

  echo 'Running license verification...'
  bazelisk test $BAZEL_OPTS //Documentation:check_licenses

  if [ -z "$SAUCE_USERNAME" ] || [ -z "$SAUCE_ACCESS_KEY" ]
  then
    echo 'Not running on Sauce Labs because env vars are not set.'
  else
    echo 'Running tests on Sauce Labs...'
    WCT_ARGS='--plugin sauce' bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed
  fi
fi
