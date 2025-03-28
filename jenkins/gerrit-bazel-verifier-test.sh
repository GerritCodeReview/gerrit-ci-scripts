#!/bin/bash -ex

. set-java.sh --branch "$TARGET_BRANCH"

cd gerrit

echo "Test with mode=$MODE"
echo '----------------------------------------------'

case $TARGET_BRANCH$MODE in
  masterrbe|stable-3.9rbe|stable-3.10rbe|stable-3.11rbe|stable-3.12rbe)
    TEST_TAG_FILTER="-flaky,-elastic,-no_rbe,-lucene"
    BAZEL_OPTS="$BAZEL_OPTS --config=remote_bb --jobs=50 --remote_header=x-buildbuddy-api-key=$BB_API_KEY"
    ;;
  masternotedb|stable-3.9notedb|stable-3.10notedb|stable-3.11notedb|stable-3.12notedb)
    TEST_TAG_FILTER="-flaky,elastic,no_rbe"
    ;;
  stable-2.*)
    TEST_TAG_FILTER="-flaky,-elastic"
    ;;
  *)
    TEST_TAG_FILTER="-flaky"
esac

export BAZEL_OPTS="$BAZEL_OPTS \
                 --flaky_test_attempts 3 \
                 --test_timeout 3600 \
                 --test_tag_filters=$TEST_TAG_FILTER"
export WCT_HEADLESS_MODE=1

java -fullversion
bazelisk version

if [[ "$MODE" == *"notedb"* ]]
then
  bazelisk test $BAZEL_OPTS //...
fi

if [[ "$MODE" == *"rbe"* ]]
then
  bazelisk test $BAZEL_OPTS //...
  export BAZEL_OPTS_WITH_LUCENE="$BAZEL_OPTS \
                 --flaky_test_attempts 3 \
                 --test_timeout 3600 \
                 --test_env GERRIT_INDEX_TYPE=lucene \
                 --test_tag_filters=lucene"
  if git grep lucene | grep BUILD | grep labels
  then
    bazelisk test $BAZEL_OPTS_WITH_LUCENE //...
  fi
fi

if [[ "$MODE" == *"polygerrit"* ]]
then

  echo 'Running Documentation tests...'
  bazelisk test $BAZEL_OPTS //tools/bzl:always_pass_test Documentation/...

  echo "Running local tests in $(google-chrome --version)"
  bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed
fi
