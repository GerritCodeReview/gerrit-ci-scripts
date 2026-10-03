#!/bin/bash -e

cd gerrit

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

. set-java.sh --branch "{branch}"

// Workaroudn to Docker executor pull issue:
// error getting credentials - err: exit status 1, out: `docker-credential-gcr/helper: could not retrieve GCR's access token:
//  docker-credential-gcr/helper: failed to detect default credentials: credentials: could not find default credentials.
export BB_GCR_WORKAROUND="--remote_exec_header=x-buildbuddy-platform.container-registry-username=_dcgcloud_token --remote_exec_header=x-buildbuddy-platform.container-registry-password=foo"

export BAZEL_OPTS="$(echo $BAZEL_OPTS | xargs) \
                   --config=remote_bb \
                   $BB_GCR_WORKAROUND \
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

exit 0
