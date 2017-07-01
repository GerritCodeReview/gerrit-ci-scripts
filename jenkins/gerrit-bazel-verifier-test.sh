#!/bin/bash -ex

cd gerrit

. set-java.sh 8

echo "Test with mode=$MODE"
echo '----------------------------------------------'

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone \
                 --test_output errors \
                 --test_summary detailed --flaky_test_attempts 3 \
                 --test_verbose_timeout_warnings --build_tests_only \
                 --nocache_test_results \
                 --test_timeout 3600 \
                 --test_tag_filters=-elastic,-flaky"

if [[ "$MODE" == *"reviewdb"* ]]
then
  bazel test $BAZEL_OPTS //...
fi

if [[ "$MODE" == *"disableChangeReviewDb"* ]]
then
  GERRIT_NOTEDB="--test_env=GERRIT_NOTEDB=DISABLE_CHANGE_REVIEW_DB"
  bazel test $GERRIT_NOTEDB $BAZEL_OPTS //...
fi

if [[ "$MODE" == *"fused"* ]]
then
  GERRIT_NOTEDB="--test_env=GERRIT_NOTEDB=FUSED"
  bazel test $GERRIT_NOTEDB $BAZEL_OPTS //...
fi

if [[ "$TARGET_BRANCH" == "master" || "$TARGET_BRANCH" == "stable-2.14" ]]
then
  if [[ "$MODE" == *"polygerrit"* ]]
  then
    if [[ "$TARGET_BRANCH" == "master" ]]
    then
      echo 'Running lint tests...'
      bazel test //polygerrit-ui/app:lint_test --test_output errors
    fi

    if [ -z "$DISPLAY" ]
    then
      echo 'Not running local tests because env var "DISPLAY" is not set.'
    else
      echo 'Running local tests...'
      bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed
    fi
    if [ -z "$SAUCE_USERNAME" ] || [ -z "$SAUCE_ACCESS_KEY" ]
    then
      echo 'Not running on Sauce Labs because env vars are not set.'
    else
      echo 'Running tests on Sauce Labs...'
      WCT_ARGS='--plugin sauce' bash ./polygerrit-ui/app/run_test.sh || touch ~/polygerrit-failed
    fi
  fi
fi

if [[ "$MODE" == *"codestyle"* ]]
then
  echo 'Running google-java-format check...'
  git show --diff-filter=AM --name-only HEAD | grep java$ | xargs -r ~/format/google-java-format --dry-run
fi
