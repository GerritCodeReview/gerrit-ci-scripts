#!/bin/bash -ex

case {branch} in
  master|stable-3.9)
    . set-java.sh 17
    ;;

  *)
    . set-java.sh 11
    ;;
esac

cd gerrit

echo "Test with mode=$MODE"
echo '----------------------------------------------'

case $TARGET_BRANCH$MODE in
  masterrbe|stable-3.6rbe|stable-3.7rbe|stable-3.8rbe|stable-3.9rbe)

 REMOTE_EXECUTOR_CONFIG="--remote_executor=grpcs://remote.buildbuddy.io \
                          --host_platform=@buildbuddy_toolchain//:platform \
                          --platforms=@buildbuddy_toolchain//:platform \
                          --extra_execution_platforms=@buildbuddy_toolchain//:platform \
                          --crosstool_top=@buildbuddy_toolchain//:toolchain \
                          --extra_toolchains=@buildbuddy_toolchain//:cc_toolchain \
                          --define=EXECUTOR=remote \
                          --bes_results_url=https://app.buildbuddy.io/invocation/ \
                          --bes_backend=grpcs://remote.buildbuddy.io \
                          --remote_cache=grpcs://remote.buildbuddy.io \
                          --remote_timeout=3600 \
                          --remote_upload_local_results \
                          --remote_download_minimal \
                          --jobs=50 \
                          --verbose_failures \
                          --tool_java_language_version=11 \
                          --tool_java_runtime_version=remotejdk_11 \
                          --java_language_version=11 \
                          --java_runtime_version=remotejdk_11 \
                          --remote_header=x-buildbuddy-api-key=$BUILD_BUDDY_API_KEY"

    TEST_TAG_FILTER="-flaky,-elastic,-no_rbe"
#    BAZEL_OPTS="$BAZEL_OPTS --config=remote --remote_instance_name=projects/gerritcodereview-ci/instances/default_instance"
    BAZEL_OPTS="$BAZEL_OPTS $REMOTE_EXECUTOR_CONFIG"
    ;;
  masternotedb|stable-3.6notedb|stable-3.7notedb|stable-3.8notedb|stable-3.9notedb)
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
                 --test_tag_filters=$TEST_TAG_FILTER \
                 --test_env DOCKER_HOST=$DOCKER_HOST"
export WCT_HEADLESS_MODE=1

java -fullversion
bazelisk version

if [[ "$MODE" == *"notedb"* ]]
then
  GERRIT_NOTEDB="--test_env=GERRIT_NOTEDB=ON"
  bazelisk test $GERRIT_NOTEDB $BAZEL_OPTS //...
fi

if [[ "$MODE" == *"rbe"* ]]
then
  cat <<EOL >> WORKSPACE
  http_archive(
      name = "io_buildbuddy_buildbuddy_toolchain",
      sha256 = "e899f235b36cb901b678bd6f55c1229df23fcbc7921ac7a3585d29bff2bf9cfd",
      strip_prefix = "buildbuddy-toolchain-fd351ca8f152d66fc97f9d98009e0ae000854e8f",
      urls = ["https://github.com/buildbuddy-io/buildbuddy-toolchain/archive/fd351ca8f152d66fc97f9d98009e0ae000854e8f.tar.gz"],
  )

  load("@io_buildbuddy_buildbuddy_toolchain//:deps.bzl", "buildbuddy_deps")
  buildbuddy_deps()

  load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "UBUNTU20_04_IMAGE", "buildbuddy")
  buildbuddy(
      name = "buildbuddy_toolchain",
      container_image = UBUNTU20_04_IMAGE,
  )
  EOL
  bazelisk test $BAZEL_OPTS //...
fi

if [[ "$MODE" == *"polygerrit"* ]]
then

  echo 'Running Documentation tests...'
  bazelisk test $BAZEL_OPTS //tools/bzl:always_pass_test Documentation/...

  echo "Running local tests in $(google-chrome --version)"
  bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed
fi
