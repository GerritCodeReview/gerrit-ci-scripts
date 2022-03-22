#!/bin/bash -e

case "$TARGET_BRANCH" in
  stable-3.3|stable-3.4)
    . set-java.sh 8
    ;;
  *)
    . set-java.sh 11
    ;;
esac

cd gerrit

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

export BAZEL_OPTS="$BAZEL_OPTS \
                   --flaky_test_attempts 3 \
                   --test_timeout 3600 \
                   --test_tag_filters=-flaky \
                   --test_env DOCKER_HOST=$DOCKER_HOST"
export WCT_HEADLESS_MODE=1

java -fullversion
bazelisk version

echo 'Test in NoteDb mode'
echo '----------------------------------------------'
bazelisk test --test_env=GERRIT_NOTEDB=ON $BAZEL_OPTS //...

echo "Test PolyGerrit locally in $(google-chrome --version)"
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

exit 0
