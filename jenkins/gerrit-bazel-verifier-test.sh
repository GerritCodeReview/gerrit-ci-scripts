#!/bin/bash -ex

. set-java.sh 8

cd gerrit

echo "Test with mode=$MODE"
echo '----------------------------------------------'

case $TARGET_BRANCH in
  stable-2.*)
    TEST_TAG_FILTER="-flaky,-elastic"
    ;;
  *)
    TEST_TAG_FILTER="-flaky"
esac

export BAZEL_OPTS="$BAZEL_OPTS --spawn_strategy=worker --genrule_strategy=standalone \
                 --test_output errors \
                 --test_summary detailed --flaky_test_attempts 3 \
                 --test_verbose_timeout_warnings --build_tests_only \
                 --test_timeout 3600 \
                 --test_tag_filters=$TEST_TAG_FILTER \
                 --test_env DOCKER_HOST=$DOCKER_HOST"
export WCT_HEADLESS_MODE=1

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

  echo 'Running Documentation tests...'
  bazelisk test $BAZEL_OPTS //tools/bzl:always_pass_test Documentation/...

  echo 'Running local tests...'
  bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed

  if [ -z "$SAUCE_USERNAME" ] || [ -z "$SAUCE_ACCESS_KEY" ]
  then
    echo 'Not running on Sauce Labs because env vars are not set.'
  else
    echo 'Running tests on Sauce Labs...'
    WCT_ARGS='--plugin sauce' bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed
  fi
fi
