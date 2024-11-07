#!/bin/bash -e

cd gerrit

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

. set-java.sh --branch "{branch}"

export BAZEL_OPTS="$(echo $BAZEL_OPTS | xargs) \
                   --jobs=50 \
                   --remote_header=x-buildbuddy-api-key=$BB_API_KEY \
                   --flaky_test_attempts 3 \
                   --test_timeout 3600 \
                   --test_tag_filters=-flaky"

case {branch} in
  stable-3.11)
    export BAZEL_OPTS="$BAZEL_OPTS --config=remote21_bb"
    ;;
  *)
    export BAZEL_OPTS="$BAZEL_OPTS --config=remote_bb"
  ;;
esac

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
