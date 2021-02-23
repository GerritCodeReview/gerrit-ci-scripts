#!/bin/bash -e

. set-java.sh 8

cd gerrit

if git show --diff-filter=AM --name-only --pretty="" HEAD | grep -q .bazelversion
then
  export BAZEL_OPTS=""
fi

export BAZEL_OPTS="$BAZEL_OPTS \
                   --test_output errors \
                   --flaky_test_attempts 3 \
                   --test_verbose_timeout_warnings --build_tests_only \
                   --test_timeout 3600 \
                   --test_tag_filters=-flaky \
                   --test_env DOCKER_HOST=$DOCKER_HOST"
export WCT_HEADLESS_MODE=1

java -fullversion
bazelisk version

if [ "{branch}" == "stable-2.16" ]
then
  echo 'Test in ReviewDb mode'
  echo '----------------------------------------------'
  bazelisk test --test_env=GERRIT_NOTEDB=OFF $BAZEL_OPTS //...
fi

echo 'Test in NoteDb mode'
echo '----------------------------------------------'
bazelisk test --test_env=GERRIT_NOTEDB=ON $BAZEL_OPTS //...

echo 'Test PolyGerrit locally'
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
