#!/bin/bash -e

cd gerrit

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

. set-java.sh --branch "{branch}"

export BAZEL_OPTS="$(echo $BAZEL_OPTS | xargs) \
                   --config=remote_bb \
                   --jobs=50 \
                   --remote_header=x-buildbuddy-api-key=$BB_API_KEY \
                   --flaky_test_attempts 3 \
                   --test_timeout 3600 \
                   --test_tag_filters=-flaky"

export WCT_HEADLESS_MODE=1

java -fullversion
bazelisk version

echo 'Test in NoteDb mode'
echo '----------------------------------------------'
bazelisk test $BAZEL_OPTS //...

echo "Test PolyGerrit locally in $(google-chrome --version)"
echo '----------------------------------------------'
bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed

# Screenshot regression tests are a separate Bazel target introduced on
# master only for now; mirrors LUCI's existing master-only coverage. To
# extend to a stable branch later, add it to the condition below.
if [[ "{branch}" == "master" ]]
then
  echo "Test PolyGerrit screenshot baselines in $(google-chrome --version)"
  echo '----------------------------------------------'
  bazelisk test $BAZEL_OPTS //polygerrit-ui:web_test_runner_screenshots \
    || touch ~/polygerrit-failed
fi

exit 0
