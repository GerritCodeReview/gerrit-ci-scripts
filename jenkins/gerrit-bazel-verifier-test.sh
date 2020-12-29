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

if [[ "$MODE" == *"rbe"* ]]
then
  TEST_TAG_FILTER="-flaky,-elastic,-git-protocol-v2"
  export BAZEL_OPTS="$BAZEL_OPTS $BAZEL_RBE_OPTS"
else
  export BAZEL_OPTS="$BAZEL_OPTS \
                   $BAZEL_REMOTE_OPTS \
                   --test_env DOCKER_HOST=$DOCKER_HOST"
fi

# Only verify that cannot be tested on RBE
if [[ "$MODE" == *"notedb"* && "$TARGET_BRANCH" == "master" ]]
  TEST_TAG_FILTER="-flaky,elastic,git-protocol-v2"
fi

export BAZEL_OPTS="$BAZEL_OPTS \
                 --test_output errors \
                 --test_summary detailed --flaky_test_attempts 3 \
                 --test_verbose_timeout_warnings --build_tests_only \
                 --test_timeout 3600 \
                 --test_tag_filters=$TEST_TAG_FILTER"

echo "BAZEL_OPTS is:"
echo $BAZEL_OPTS

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

if [[ "$MODE" == *"rbe"* ]]
then
  bazelisk test $BAZEL_OPTS //...
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
