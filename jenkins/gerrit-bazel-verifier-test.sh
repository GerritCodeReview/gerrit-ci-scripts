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

if [[ "$MODE" == *"notedb"* ]]
then
  GERRIT_NOTEDB="--test_env=GERRIT_NOTEDB=ON"
  bazel test $GERRIT_NOTEDB $BAZEL_OPTS //...
fi
