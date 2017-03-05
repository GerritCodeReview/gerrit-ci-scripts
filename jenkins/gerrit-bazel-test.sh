#!/bin/bash -e

cd gerrit

export BAZEL_OPTS="--spawn_strategy=standalone --genrule_strategy=standalone \
                   --test_output errors \
                   --test_summary detailed --flaky_test_attempts 3 \
                   --test_verbose_timeout_warnings --build_tests_only \
                   --nocache_test_results \
                   --test_timeout 3600 \
                   --test_tag_filters=-elastic,-flaky"

echo 'Test in default DB mode'
echo '----------------------------------------------'
bazel test $BAZEL_OPTS //...

echo 'Test in Note DB mode'
echo '----------------------------------------------'
bazel test --test_env=GERRIT_NOTEDB=READ_WRITE $BAZEL_OPTS //...

echo -e '#!/bin/bash' > polygerrit_log.sh
echo -e 'if [[ -n $(find ~/.cache/bazel/ -name "test.log") ]];' >> polygerrit_log.sh
echo -e 'then' >> polygerrit_log.sh
echo -e '	find ~/.cache/bazel/ -name 'test.log' -exec cat {} \; && exit -1;' >> polygerrit_log.sh
echo -e 'fi' >> polygerrit_log.sh

chmod +x ./polygerrit_log.sh

echo 'Test PolyGerrit locally'
echo '----------------------------------------------'
bash ./polygerrit-ui/app/run_test.sh || ./polygerrit_log.sh

if [ -z "$SAUCE_USERNAME" ] || [ -z "$SAUCE_ACCESS_KEY" ]
then
  echo 'Not running on Sauce Labs because env vars are not set.'
else
  echo 'Test PolyGerrit on Sauce Labs'
  echo '----------------------------------------------'
  WCT_ARGS='--plugin sauce' bash ./polygerrit-ui/app/run_test.sh || ./polygerrit_log.sh
fi

exit 0
