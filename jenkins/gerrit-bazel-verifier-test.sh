#!/bin/bash -ex

. set-java.sh --branch "$TARGET_BRANCH"

cd gerrit

echo "Test with mode=$MODE"
echo '----------------------------------------------'

case $TARGET_BRANCH$MODE in
  masterrbe|stable-3.12rbe|stable-3.13rbe|stable-3.14rbe)
    TEST_TAG_FILTER="-flaky,-elastic,-no_rbe,-lucene"

    # Workaround to Docker executor pull issue:
    # error getting credentials - err: exit status 1, out: `docker-credential-gcr/helper: could not retrieve GCR's access token:
    # docker-credential-gcr/helper: failed to detect default credentials: credentials: could not find default credentials.
    export BB_GCR_WORKAROUND="--remote_exec_header=x-buildbuddy-platform.container-registry-username=_dcgcloud_token --remote_exec_header=x-buildbuddy-platform.container-registry-password=foo"

    BAZEL_OPTS="$BAZEL_OPTS --config=remote_bb --jobs=50 --remote_header=x-buildbuddy-api-key=$BB_API_KEY $BB_GCR_WORKAROUND"
    ;;
  masternotedb|stable-3.12notedb|stable-3.13notedb|stable-3.14notedb)
    TEST_TAG_FILTER="-flaky,elastic,no_rbe"
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
